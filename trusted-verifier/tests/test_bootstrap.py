import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
import unittest
from unittest import mock
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TRUSTED = ROOT / "trusted-verifier"
WORKFLOW = ".github/workflows/check.yml"
TRUSTED_WORKFLOW = ROOT / ".github/workflows/trusted-cameraapp-gate.yml"
CI_CHECK = "scripts/ci-check.sh"
AUTHORIZED_PATHS = {
    "README.md",
    "SECURITY.md",
    "docs/plans/2026-06-21-cameraapp-make-authority.md",
    "scripts/check-baseline.sh",
    "scripts/test-makefile-root.sh",
}
UNAUTHORIZED_PATH = "Application/build.gradle"


def run(command, cwd=None, env=None):
    argv = [str(part) for part in command]
    try:
        return subprocess.run(
            argv,
            cwd=cwd,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )
    except FileNotFoundError as error:
        return subprocess.CompletedProcess(argv, 127, f"missing executable: {error.filename}\n")


def git(repository, *arguments):
    result = run(["/usr/bin/git", *arguments], cwd=repository)
    if result.returncode != 0:
        raise AssertionError(result.stdout)
    return result.stdout.strip()


def load_environment_verifier():
    path = TRUSTED / "verify_environment.py"
    if not path.is_file():
        raise AssertionError("trusted environment verifier is missing")
    spec = importlib.util.spec_from_file_location("cameraapp_trusted_environment", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class TrustedDirectGateBootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temporary = Path(tempfile.mkdtemp(prefix="cameraapp-trusted-gate-test-"))
        self.base = self.temporary / "base"
        self.candidate = self.temporary / "candidate"
        self.receipt = self.temporary / "receipt.json"

    def tearDown(self):
        shutil.rmtree(self.temporary, ignore_errors=True)

    def make_v2_style_repository(self):
        shutil.rmtree(self.base, ignore_errors=True)
        shutil.rmtree(self.candidate, ignore_errors=True)
        self.receipt.unlink(missing_ok=True)
        self.base.mkdir()
        git(self.base, "init", "--quiet", "--initial-branch=master")
        git(self.base, "config", "user.name", "CameraApp Trusted Gate Test")
        git(self.base, "config", "user.email", "cameraapp-trusted-gate@example.invalid")

        workflow = self.base / WORKFLOW
        workflow.parent.mkdir(parents=True)
        workflow.write_text(
            "\n".join(
                [
                    "name: Check",
                    "on:",
                    "  push:",
                    "  pull_request:",
                    "  workflow_dispatch:",
                    "permissions:",
                    "  contents: read",
                    "jobs:",
                    "  check:",
                    "    runs-on: ubuntu-24.04",
                    "    steps:",
                    "      - name: Run full verification and instrumentation",
                    "        run: timeout 22m ./scripts/ci-check.sh",
                    "",
                ]
            ),
            encoding="utf-8",
        )
        trusted_workflow = self.base / ".github/workflows/trusted-cameraapp-gate.yml"
        shutil.copy2(TRUSTED_WORKFLOW, trusted_workflow)
        ci_check = self.base / CI_CHECK
        ci_check.parent.mkdir(parents=True)
        ci_check.write_text(
            "#!/usr/bin/env sh\nset -eu\nprintf '%s\\n' trusted-ci-check\n",
            encoding="utf-8",
        )
        ci_check.chmod(0o755)
        (self.base / "Application").mkdir()

        shutil.copytree(TRUSTED, self.base / "trusted-verifier", ignore=shutil.ignore_patterns("__pycache__"))
        git(self.base, "add", ".")
        git(self.base, "commit", "--quiet", "-m", "test: trusted direct gate base")
        base_sha = git(self.base, "rev-parse", "HEAD")

        clone = run(["/usr/bin/git", "clone", "--quiet", "--no-hardlinks", self.base, self.candidate])
        self.assertEqual(clone.returncode, 0, clone.stdout)
        git(self.candidate, "config", "user.name", "CameraApp Malicious Candidate")
        git(self.candidate, "config", "user.email", "cameraapp-malicious-candidate@example.invalid")
        return base_sha

    def make_semantic_repository(self):
        shutil.rmtree(self.base, ignore_errors=True)
        shutil.rmtree(self.candidate, ignore_errors=True)
        self.receipt.unlink(missing_ok=True)
        self.base.mkdir()
        git(self.base, "init", "--quiet", "--initial-branch=master")
        git(self.base, "config", "user.name", "CameraApp Trusted Gate Test")
        git(self.base, "config", "user.email", "cameraapp-trusted-gate@example.invalid")

        trusted_workflow = self.base / ".github/workflows/trusted-cameraapp-gate.yml"
        trusted_workflow.parent.mkdir(parents=True)
        shutil.copy2(TRUSTED_WORKFLOW, trusted_workflow)
        shutil.copytree(TRUSTED, self.base / "trusted-verifier", ignore=shutil.ignore_patterns("__pycache__"))
        policy = json.loads((TRUSTED / "policy.json").read_text(encoding="utf-8"))
        for path in policy["expected_files"]:
            target = self.base / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text("pre-reviewed CameraApp semantic bytes\n", encoding="utf-8")

        git(self.base, "add", ".")
        git(self.base, "commit", "--quiet", "-m", "test: trusted direct gate base")
        base_sha = git(self.base, "rev-parse", "HEAD")

        clone = run(["/usr/bin/git", "clone", "--quiet", "--no-hardlinks", self.base, self.candidate])
        self.assertEqual(clone.returncode, 0, clone.stdout)
        git(self.candidate, "config", "user.name", "CameraApp Semantic Candidate")
        git(self.candidate, "config", "user.email", "cameraapp-semantic-candidate@example.invalid")
        for path, contract in policy["expected_files"].items():
            target = self.candidate / path
            target.write_bytes((TRUSTED / contract["template"]).read_bytes())
            target.chmod(int(contract["mode"], 8) & 0o777)
            git(self.candidate, "add", path)
        git(self.candidate, "commit", "--quiet", "-m", "fix: apply reviewed CameraApp semantic bytes")
        return base_sha, git(self.candidate, "rev-parse", "HEAD")

    def policy(self):
        return json.loads((TRUSTED / "policy.json").read_text(encoding="utf-8"))

    def verify_candidate(self, base_sha, head_sha, env=None):
        return run(
            [
                self.base / "trusted-verifier" / "run-hermetic.sh",
                "--base-repository",
                self.base,
                "--candidate-repository",
                self.candidate,
                "--base-sha",
                base_sha,
                "--head-sha",
                head_sha,
                "--receipt",
                self.receipt,
            ],
            env=env,
        )

    def commit_noop_gate_replacement(self):
        ci_check = self.candidate / CI_CHECK
        ci_check.write_text("#!/usr/bin/env sh\nexit 0\n", encoding="utf-8")
        ci_check.chmod(0o755)
        git(self.candidate, "add", CI_CHECK)
        git(self.candidate, "commit", "--quiet", "-m", "test: replace direct gate with no-op")
        return git(self.candidate, "rev-parse", "HEAD")

    def commit_symlink_gate_replacement(self):
        ci_check = self.candidate / CI_CHECK
        ci_check.unlink()
        ci_check.symlink_to("/usr/bin/true")
        git(self.candidate, "add", CI_CHECK)
        git(self.candidate, "commit", "--quiet", "-m", "test: replace direct gate with true symlink")
        return git(self.candidate, "rev-parse", "HEAD")

    def assert_workflow_line_preserved(self):
        base_workflow = (self.base / WORKFLOW).read_text(encoding="utf-8")
        candidate_workflow = (self.candidate / WORKFLOW).read_text(encoding="utf-8")
        self.assertIn("run: timeout 22m ./scripts/ci-check.sh", candidate_workflow)
        self.assertEqual(base_workflow, candidate_workflow)

    def assert_rejected_as_candidate_gate_replacement(self, result):
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("candidate changed-file boundary differs", result.stdout)
        self.assertIn(CI_CHECK, result.stdout)
        self.assertFalse(self.receipt.exists())

    def amend_candidate(self):
        git(self.candidate, "add", ".")
        git(self.candidate, "commit", "--amend", "--quiet", "--no-edit")
        return git(self.candidate, "rev-parse", "HEAD")

    def test_pull_request_candidate_cannot_noop_or_symlink_direct_gate(self):
        for attack in ("noop", "symlink"):
            with self.subTest(attack=attack):
                base_sha = self.make_v2_style_repository()
                if attack == "noop":
                    head_sha = self.commit_noop_gate_replacement()
                    mode = git(self.candidate, "ls-tree", "-r", "--format=%(objectmode)", head_sha, CI_CHECK)
                    self.assertEqual(mode, "100755")
                else:
                    head_sha = self.commit_symlink_gate_replacement()
                    mode = git(self.candidate, "ls-tree", "-r", "--format=%(objectmode)", head_sha, CI_CHECK)
                    self.assertEqual(mode, "120000")
                self.assert_workflow_line_preserved()

                result = self.verify_candidate(base_sha, head_sha)

                self.assert_rejected_as_candidate_gate_replacement(result)

    def test_workflow_is_base_owned_fork_safe_and_nonexecuting(self):
        self.assertTrue(TRUSTED_WORKFLOW.is_file(), "trusted pull_request_target workflow is missing")
        text = TRUSTED_WORKFLOW.read_text(encoding="utf-8")
        required = (
            "pull_request_target:",
            "permissions:\n  actions: read\n  contents: read",
            "environment:\n      name: cameraapp-trusted-verifier-v1",
            "ref: ${{ github.workflow_sha }}",
            "HEAD_REPO: ${{ github.event.pull_request.head.repo.full_name }}",
            "HEAD_SHA: ${{ github.event.pull_request.head.sha }}",
            '/usr/bin/git -C candidate fetch --no-tags --filter=blob:none --depth=2 pr "$HEAD_SHA"',
            '/usr/bin/git -C candidate checkout --detach "$HEAD_SHA"',
            "persist-credentials: false",
            "set-safe-directory: false",
            "submodules: false",
            "lfs: false",
            "/usr/bin/python3 -I -S -B trusted-base/trusted-verifier/verify_environment.py",
            "GITHUB_API_TOKEN: ${{ github.token }}",
            'GITHUB_API_TOKEN="$GITHUB_API_TOKEN"',
            "/bin/sh -p trusted-base/trusted-verifier/run-hermetic.sh",
        )
        for contract in required:
            self.assertIn(contract, text)
        forbidden = (
            "secrets.",
            "contents: write",
            "pull-requests: write",
            "actions/cache",
            "candidate/Makefile",
            "candidate/scripts",
            "make check",
            "./gradlew",
        )
        for contract in forbidden:
            self.assertNotIn(contract, text)
        self.assertLess(text.index("Verify protected environment policy"), text.index("Fetch candidate as untrusted data"))
        self.assertNotRegex(text, r"(?m)^\s*run:\s*.*candidate")

    def test_environment_api_requests_use_explicit_bearer_token(self):
        verifier = load_environment_verifier()
        requests = []

        class Response:
            status = 200

            @staticmethod
            def read():
                return b'{"ok": true}'

        class Connection:
            def __init__(self, host, timeout, context):
                self.host = host
                self.timeout = timeout
                self.context = context

            def request(self, method, path, headers):
                requests.append((method, path, headers))

            @staticmethod
            def getresponse():
                return Response()

            @staticmethod
            def close():
                pass

        with mock.patch.object(verifier.http.client, "HTTPSConnection", Connection):
            payload = verifier.fetch_json("/repos/garethpaul/CameraApp/environments/test", "test-token")

        self.assertEqual(payload, {"ok": True})
        self.assertEqual(len(requests), 1)
        self.assertEqual(requests[0][2]["Authorization"], "Bearer test-token")

        with self.assertRaises(verifier.EnvironmentError):
            verifier.fetch_json("/repos/garethpaul/CameraApp/environments/test", "")

    def test_policy_authorizes_only_reviewed_documentation_and_harness_paths(self):
        policy = self.policy()

        self.assertEqual(set(policy["expected_files"]), AUTHORIZED_PATHS)
        self.assertNotIn(UNAUTHORIZED_PATH, policy["expected_files"])
        self.assertNotIn(".github/workflows/trusted-cameraapp-gate.yml", policy["expected_files"])

    def test_environment_preflight_rejects_environment_or_app_mismatch(self):
        verifier = load_environment_verifier()
        environment = {
            "name": "cameraapp-trusted-verifier-v1",
            "deployment_branch_policy": {
                "protected_branches": False,
                "custom_branch_policies": True,
            },
        }
        policies = {
            "total_count": 1,
            "branch_policies": [{"name": "master", "type": "branch"}],
        }
        verifier.validate_environment(
            environment,
            policies,
            "cameraapp-trusted-verifier-v1",
            "github-actions",
        )
        with self.assertRaises(verifier.EnvironmentError):
            verifier.validate_environment(environment, policies, "production", "github-actions")
        with self.assertRaises(verifier.EnvironmentError):
            verifier.validate_environment(
                environment,
                policies,
                "cameraapp-trusted-verifier-v1",
                "untrusted-app",
            )

    def test_exact_reviewed_semantic_candidate_is_accepted(self):
        base_sha, head_sha = self.make_semantic_repository()

        result = self.verify_candidate(base_sha, head_sha)

        self.assertEqual(result.returncode, 0, result.stdout)
        receipt = json.loads(self.receipt.read_text(encoding="utf-8"))
        self.assertEqual(receipt["status"], "passed")
        self.assertEqual(receipt["trusted_base_sha"], base_sha)
        self.assertEqual(receipt["candidate_head_sha"], head_sha)
        self.assertEqual(set(receipt["verified_files"]), set(self.policy()["expected_files"]))

    def test_candidate_workflow_spoofing_extra_commits_files_and_modes_are_rejected(self):
        cases = {
            "workflow-spoof": lambda: (
                (self.candidate / ".github/workflows/check.yml").parent.mkdir(parents=True, exist_ok=True),
                (self.candidate / ".github/workflows/check.yml").write_text("name: spoof\n", encoding="utf-8"),
                self.amend_candidate(),
                "candidate changed-file boundary differs",
            ),
            "extra-file": lambda: (
                (self.candidate / UNAUTHORIZED_PATH).parent.mkdir(parents=True, exist_ok=True),
                (self.candidate / UNAUTHORIZED_PATH).write_text("extra\n", encoding="utf-8"),
                self.amend_candidate(),
                "candidate changed-file boundary differs",
            ),
            "extra-commit": lambda: (
                (self.candidate / "README.md").write_text("extra commit\n", encoding="utf-8"),
                git(self.candidate, "add", "README.md"),
                git(self.candidate, "commit", "--quiet", "-m", "test: extra commit"),
                git(self.candidate, "rev-parse", "HEAD"),
                "trusted base must be the candidate's sole parent",
            ),
            "mode": lambda: (
                (self.candidate / sorted(self.policy()["expected_files"])[0]).chmod(0o755),
                git(self.candidate, "add", sorted(self.policy()["expected_files"])[0]),
                git(self.candidate, "commit", "--amend", "--quiet", "--no-edit"),
                git(self.candidate, "rev-parse", "HEAD"),
                "candidate mode differs from reviewed mode",
            ),
        }
        for name, mutate in cases.items():
            with self.subTest(name=name):
                base_sha, _ = self.make_semantic_repository()
                values = mutate()
                head_sha = next(value for value in values if isinstance(value, str) and len(value) == 40)
                expected = values[-1]
                result = self.verify_candidate(base_sha, head_sha)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn(expected, result.stdout)
                self.assertFalse(self.receipt.exists())

    def test_shallow_candidate_history_is_rejected(self):
        base_sha, head_sha = self.make_semantic_repository()
        shallow = self.temporary / "shallow"
        clone = run([
            "/usr/bin/git",
            "clone",
            "--quiet",
            "--depth",
            "1",
            f"file://{self.candidate}",
            shallow,
        ])
        self.assertEqual(clone.returncode, 0, clone.stdout)
        self.candidate = shallow

        result = self.verify_candidate(base_sha, head_sha)

        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("trusted base must be the candidate's sole parent", result.stdout)
        self.assertFalse(self.receipt.exists())

    def test_fake_tools_and_python_startup_are_ignored(self):
        base_sha, head_sha = self.make_semantic_repository()
        fake_bin = self.temporary / "fake-bin"
        fake_bin.mkdir()
        fake_git_marker = self.temporary / "fake-git-ran"
        fake_python_marker = self.temporary / "fake-python-ran"
        startup_marker = self.temporary / "startup-ran"
        for name, marker in (("git", fake_git_marker), ("python3", fake_python_marker)):
            tool = fake_bin / name
            tool.write_text(f"#!/bin/sh\n: > {str(marker)!r}\nexit 66\n", encoding="utf-8")
            tool.chmod(0o755)
        startup = self.temporary / "startup.py"
        startup.write_text(
            f"from pathlib import Path\nPath({str(startup_marker)!r}).write_text('ran')\n",
            encoding="utf-8",
        )
        env = os.environ.copy()
        env.update(
            {
                "PATH": f"{fake_bin}:{env.get('PATH', '')}",
                "PYTHONPATH": str(self.temporary),
                "PYTHONSTARTUP": str(startup),
                "PYTHONINSPECT": "1",
                "BASH_ENV": str(startup),
                "ENV": str(startup),
            }
        )

        result = self.verify_candidate(base_sha, head_sha, env=env)

        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertFalse(fake_git_marker.exists(), result.stdout)
        self.assertFalse(fake_python_marker.exists(), result.stdout)
        self.assertFalse(startup_marker.exists(), result.stdout)

    def test_archive_path_and_size_limits_reject_hostile_candidates(self):
        cases = {
            "backslash-path": lambda: (
                (self.candidate / "Application\\evil.txt").write_text("evil\n", encoding="utf-8"),
                self.amend_candidate(),
                "candidate path uses unsupported separator",
            ),
            "oversized-reviewed-blob": lambda: (
                (self.candidate / sorted(self.policy()["expected_files"])[0]).write_text(
                    "x" * (self.policy()["expected_files"][sorted(self.policy()["expected_files"])[0]]["max_bytes"] + 1),
                    encoding="utf-8",
                ),
                self.amend_candidate(),
                "candidate blob exceeds trusted size limit",
            ),
        }
        for name, mutate in cases.items():
            with self.subTest(name=name):
                base_sha, _ = self.make_semantic_repository()
                values = mutate()
                head_sha = next(value for value in values if isinstance(value, str) and len(value) == 40)
                expected = values[-1]
                result = self.verify_candidate(base_sha, head_sha)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn(expected, result.stdout)
                self.assertFalse(self.receipt.exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
