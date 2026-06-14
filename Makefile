.PHONY: build check lint test toolchain verify

ANDROID_HOME ?= /home/gjones/android-sdk
JAVA_HOME ?=
GRADLE ?= ./gradlew
ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
GRADLE_COMMAND := $(if $(filter ./%,$(GRADLE)),$(ROOT)$(patsubst ./%,%,$(GRADLE)),$(GRADLE))
GRADLE_ENV := ANDROID_HOME="$(ANDROID_HOME)" ANDROID_SDK_ROOT="$(ANDROID_HOME)" JAVA_HOME="$(JAVA_HOME)"

toolchain:
	@if [ ! -x "$(JAVA_HOME)/bin/java" ]; then \
		echo "JAVA_HOME must point to JDK 17." >&2; \
		exit 1; \
	fi
	@version="$$("$(JAVA_HOME)/bin/java" -XshowSettings:properties -version 2>&1 | sed -n 's/^[[:space:]]*java.specification.version = //p')"; \
	if [ "$$version" != "17" ]; then \
		echo "CameraApp requires JDK 17; found $$version." >&2; \
		exit 1; \
	fi
	@if [ ! -f "$(ANDROID_HOME)/platforms/android-36/android.jar" ]; then \
		echo "Android SDK platform 36 is required under $(ANDROID_HOME)." >&2; \
		exit 1; \
	fi
	@if [ ! -x "$(ANDROID_HOME)/build-tools/36.1.0/aapt2" ]; then \
		echo "Android SDK build-tools 36.1.0 are required under $(ANDROID_HOME)." >&2; \
		exit 1; \
	fi

lint: toolchain
	$(ROOT)scripts/check-baseline.sh
	$(GRADLE_ENV) $(GRADLE_COMMAND) -p "$(ROOT)" :Application:lintDebug :Application:lintRelease --no-daemon
	@for report in \
		"$(ROOT)Application/build/reports/lint-results-debug.xml" \
		"$(ROOT)Application/build/reports/lint-results-release.xml"; do \
		if [ ! -f "$$report" ] || grep -Eq '<issue([[:space:]>])' "$$report"; then \
			echo "Android lint must produce zero-finding debug and release XML reports." >&2; \
			exit 1; \
		fi; \
	done

test: toolchain
	$(ROOT)scripts/check-baseline.sh
	$(GRADLE_ENV) $(GRADLE_COMMAND) -p "$(ROOT)" :Application:assembleDebugAndroidTest --no-daemon

build: toolchain
	$(ROOT)scripts/check-baseline.sh
	$(GRADLE_ENV) $(GRADLE_COMMAND) -p "$(ROOT)" :Application:assembleDebug --no-daemon

verify: lint test build

check: verify
