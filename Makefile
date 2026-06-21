.DEFAULT_GOAL := check
.PHONY: __repository-make-authority build check lint root-test test toolchain verify
.SECONDEXPANSION:

override SHELL := /bin/sh
override .SHELLFLAGS := -c
build check lint root-test test toolchain verify __repository-make-authority: override SHELL := /bin/sh
build check lint root-test test toolchain verify __repository-make-authority: override .SHELLFLAGS := -c

ifeq ($(origin ANDROID_HOME),undefined)
override ANDROID_HOME := /home/gjones/android-sdk
else
override ANDROID_HOME := $(value ANDROID_HOME)
endif
ifeq ($(origin JAVA_HOME),undefined)
override JAVA_HOME :=
else
override JAVA_HOME := $(value JAVA_HOME)
endif
override ROOT := $(shell path='$(subst ','"'"',$(value MAKEFILE_LIST))'; path=$$(/usr/bin/printf '%s' "$$path" | /usr/bin/sed 's/^ //'); [ -f "$$path" ] || exit 1; directory=$$(/usr/bin/dirname -- "$$path"); CDPATH= cd -- "$$directory" && /bin/pwd -P)
ifeq ($(origin GRADLE),undefined)
override GRADLE := $(ROOT)/gradlew
else
override GRADLE := $(value GRADLE)
endif
ifeq ($(origin SKIP_ANDROID_INSTRUMENTATION),undefined)
override SKIP_ANDROID_INSTRUMENTATION := 0
else
override SKIP_ANDROID_INSTRUMENTATION := $(value SKIP_ANDROID_INSTRUMENTATION)
endif
export ANDROID_HOME GRADLE JAVA_HOME ROOT SKIP_ANDROID_INSTRUMENTATION

override REPOSITORY_MAKE_DOLLAR := $$
override REPOSITORY_MAKE_OPEN := (
override REPOSITORY_MAKE_OPEN_BRACE := {
define REPOSITORY_REJECT_MAKE_SYNTAX
ifneq ($$(findstring $$(REPOSITORY_MAKE_DOLLAR)$$(REPOSITORY_MAKE_OPEN),$$(value $(1))),)
$$(error $(1) must be a literal value, not Make syntax)
endif
ifneq ($$(findstring $$(REPOSITORY_MAKE_DOLLAR)$$(REPOSITORY_MAKE_OPEN_BRACE),$$(value $(1))),)
$$(error $(1) must be a literal value, not Make syntax)
endif
endef
$(foreach variable,ANDROID_HOME GRADLE JAVA_HOME SKIP_ANDROID_INSTRUMENTATION,$(eval $(call REPOSITORY_REJECT_MAKE_SYNTAX,$(variable))))

ifeq ($(strip $(ROOT)),)
$(error repository Makefile path could not be resolved)
endif
ifeq ($(strip $(ANDROID_HOME)),)
$(error ANDROID_HOME must be a literal Android SDK path)
endif
ifeq ($(strip $(GRADLE)),)
$(error GRADLE must be a literal executable path)
endif
ifneq ($(strip $(SKIP_ANDROID_INSTRUMENTATION)),0)
ifneq ($(strip $(SKIP_ANDROID_INSTRUMENTATION)),1)
$(error SKIP_ANDROID_INSTRUMENTATION must be 0 or 1)
endif
endif
ifneq ($(filter command line,$(origin MAKEFLAGS)),)
$(error MAKEFLAGS must not be overridden for repository verification)
endif
override REPOSITORY_MAKE_FIRST_FLAGS := $(firstword $(MAKEFLAGS))
ifneq ($(filter -%,$(REPOSITORY_MAKE_FIRST_FLAGS)),)
override REPOSITORY_MAKE_FIRST_FLAGS :=
endif
override REPOSITORY_MAKE_SHORT_FLAGS := $(REPOSITORY_MAKE_FIRST_FLAGS) $(filter-out --%,$(filter -%,$(MAKEFLAGS)))
ifneq ($(findstring n,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring t,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring q,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring i,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(filter --just-print --dry-run --recon --touch --question --ignore-errors,$(MAKEFLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)
endif
override MAKEFILES :=
ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif

override REPOSITORY_SHELL_LITERAL = $(subst $$,$$$$,$(subst ','"'"',$1))
override REPOSITORY_ROOT_LITERAL := $(call REPOSITORY_SHELL_LITERAL,$(ROOT))
override REPOSITORY_ANDROID_HOME_LITERAL := $(call REPOSITORY_SHELL_LITERAL,$(ANDROID_HOME))
override REPOSITORY_GRADLE_LITERAL := $(call REPOSITORY_SHELL_LITERAL,$(GRADLE))
override REPOSITORY_JAVA_HOME_LITERAL := $(call REPOSITORY_SHELL_LITERAL,$(JAVA_HOME))
override REPOSITORY_SKIP_INSTRUMENTATION_LITERAL := $(call REPOSITORY_SHELL_LITERAL,$(SKIP_ANDROID_INSTRUMENTATION))

build check lint root-test test toolchain verify:: $$(if $$(filter file,$$(origin MAKEFILE_LIST)),,$$(error MAKEFILE_LIST must not be overridden))
build check lint root-test test toolchain verify:: $$(if $$(shell path=$$$$(/usr/bin/printf '%s' '$$(subst ','"'"',$$(MAKEFILE_LIST))' | /usr/bin/sed 's/^ //') && [ -f "$$$$path" ] && /usr/bin/printf '%s' ok),,$$(error repository Makefile must be loaded alone))
build check lint root-test test toolchain verify:: __repository-make-authority

__repository-make-authority::
	@:

define REPOSITORY_PUBLIC_RECIPES
root-test::
	/bin/sh '$(REPOSITORY_ROOT_LITERAL)/scripts/test-makefile-root.sh'
toolchain::
	@java='$(REPOSITORY_JAVA_HOME_LITERAL)/bin/java'; if [ -z '$(REPOSITORY_JAVA_HOME_LITERAL)' ] || [ ! -x "$$$$java" ]; then echo "JAVA_HOME must point to JDK 17." >&2; exit 1; fi
	@version="$$$$( '$(REPOSITORY_JAVA_HOME_LITERAL)/bin/java' -XshowSettings:properties -version 2>&1 | /usr/bin/sed -n 's/^[[:space:]]*java.specification.version = //p')"; if [ "$$$$version" != "17" ]; then echo "CameraApp requires JDK 17; found $$$$version." >&2; exit 1; fi
	@if [ ! -f '$(REPOSITORY_ANDROID_HOME_LITERAL)/platforms/android-36/android.jar' ]; then echo "Android SDK platform 36 is required under $(REPOSITORY_ANDROID_HOME_LITERAL)." >&2; exit 1; fi
	@if [ ! -x '$(REPOSITORY_ANDROID_HOME_LITERAL)/build-tools/36.1.0/aapt2' ]; then echo "Android SDK build-tools 36.1.0 are required under $(REPOSITORY_ANDROID_HOME_LITERAL)." >&2; exit 1; fi
lint:: toolchain
	/bin/sh '$(REPOSITORY_ROOT_LITERAL)/scripts/check-baseline.sh'
	cd '$(REPOSITORY_ROOT_LITERAL)' && ANDROID_HOME='$(REPOSITORY_ANDROID_HOME_LITERAL)' ANDROID_SDK_ROOT='$(REPOSITORY_ANDROID_HOME_LITERAL)' JAVA_HOME='$(REPOSITORY_JAVA_HOME_LITERAL)' '$(REPOSITORY_GRADLE_LITERAL)' -p '$(REPOSITORY_ROOT_LITERAL)' :Application:lintDebug --no-daemon
	cd '$(REPOSITORY_ROOT_LITERAL)' && ANDROID_HOME='$(REPOSITORY_ANDROID_HOME_LITERAL)' ANDROID_SDK_ROOT='$(REPOSITORY_ANDROID_HOME_LITERAL)' JAVA_HOME='$(REPOSITORY_JAVA_HOME_LITERAL)' '$(REPOSITORY_GRADLE_LITERAL)' -p '$(REPOSITORY_ROOT_LITERAL)' :Application:lintRelease --no-daemon
	@for report in '$(REPOSITORY_ROOT_LITERAL)/Application/build/reports/lint-results-debug.xml' '$(REPOSITORY_ROOT_LITERAL)/Application/build/reports/lint-results-release.xml'; do if [ ! -f "$$$$report" ] || /usr/bin/grep -Eq '<issue([[:space:]>])' "$$$$report"; then echo "Android lint must produce zero-finding debug and release XML reports." >&2; exit 1; fi; done
test:: toolchain
	/bin/sh '$(REPOSITORY_ROOT_LITERAL)/scripts/check-baseline.sh'
	cd '$(REPOSITORY_ROOT_LITERAL)' && ANDROID_HOME='$(REPOSITORY_ANDROID_HOME_LITERAL)' ANDROID_SDK_ROOT='$(REPOSITORY_ANDROID_HOME_LITERAL)' JAVA_HOME='$(REPOSITORY_JAVA_HOME_LITERAL)' '$(REPOSITORY_GRADLE_LITERAL)' -p '$(REPOSITORY_ROOT_LITERAL)' :Application:assembleDebugAndroidTest --no-daemon
	@if [ '$(REPOSITORY_SKIP_INSTRUMENTATION_LITERAL)' = 1 ]; then echo "SKIP_ANDROID_INSTRUMENTATION=1; instrumentation APK assembled but runtime execution skipped."; else cd '$(REPOSITORY_ROOT_LITERAL)' && ANDROID_HOME='$(REPOSITORY_ANDROID_HOME_LITERAL)' ANDROID_SDK_ROOT='$(REPOSITORY_ANDROID_HOME_LITERAL)' JAVA_HOME='$(REPOSITORY_JAVA_HOME_LITERAL)' GRADLE='$(REPOSITORY_GRADLE_LITERAL)' /bin/sh '$(REPOSITORY_ROOT_LITERAL)/scripts/run-instrumentation.sh'; fi
build:: toolchain
	/bin/sh '$(REPOSITORY_ROOT_LITERAL)/scripts/check-baseline.sh'
	cd '$(REPOSITORY_ROOT_LITERAL)' && ANDROID_HOME='$(REPOSITORY_ANDROID_HOME_LITERAL)' ANDROID_SDK_ROOT='$(REPOSITORY_ANDROID_HOME_LITERAL)' JAVA_HOME='$(REPOSITORY_JAVA_HOME_LITERAL)' '$(REPOSITORY_GRADLE_LITERAL)' -p '$(REPOSITORY_ROOT_LITERAL)' :Application:assembleDebug --no-daemon
verify:: root-test lint test build
check:: verify
endef
$(eval $(REPOSITORY_PUBLIC_RECIPES))
