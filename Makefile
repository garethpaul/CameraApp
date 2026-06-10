.PHONY: build check lint test verify

ANDROID_HOME ?= /home/gjones/android-sdk
GRADLE ?= ./gradlew
ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
GRADLE_COMMAND := $(if $(filter ./%,$(GRADLE)),$(ROOT)$(patsubst ./%,%,$(GRADLE)),$(GRADLE))

lint:
	$(ROOT)scripts/check-baseline.sh
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE_COMMAND) -p "$(ROOT)" lint --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle lint skipped."; \
	fi

test: lint

build:
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE_COMMAND) -p "$(ROOT)" assembleDebug --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle build skipped."; \
	fi

verify: lint test build

check: verify
