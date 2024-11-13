# Environment setup
SHELL := /bin/sh
PROJECT_ROOT := $(shell pwd)

# Directory structure
SRC_DIR := src
TEST_DIR := tests
TEST_ROOT := tests/root

# Source files
SRC_FILES := $(shell find $(SRC_DIR) -type f -name "*.sh")
TEST_FILES := $(shell find $(TEST_DIR) -type f -name "*_spec.sh")
SCRIPT_FILES := $(shell find scripts -type f -name "*.sh")
ALL_SHELL_FILES := $(SRC_FILES) $(TEST_FILES) $(SCRIPT_FILES)

# Test environment
export PURR_TEST := 1
export PURR_ROOT := $(TEST_ROOT)
export PURR_DATA := $(TEST_ROOT)/.local/share
export PURR_CONFIG := $(TEST_ROOT)/.config
export PURR_CACHE := $(TEST_ROOT)/.cache
export PURR_LIB := $(PROJECT_ROOT)/$(SRC_DIR)/lib
export PURR_BIN := $(PROJECT_ROOT)/$(SRC_DIR)/bin

help: ## Show this help
	@./scripts/generate-help.sh

background: ## Generate project background documentation
	@./scripts/generate-background.sh > BACKGROUND.md

setup: ## Setup development environment
	@./scripts/setup.sh

doctor: ## Run developer system checks
	@./scripts/doctor.sh

clean: ## Clean build artifacts and development environment
	@./scripts/clean.sh

lint: ## Run linting checks
	@./scripts/lint.sh

# test: ## Run all tests
# 	@./scripts/test.sh

# format: ## Format source files
# 	@shfmt -i 2 -ci -sr -w $(SRC_FILES)

# publish: ## Publish a release
# 	@./scripts/publish.sh "$(VERSION)"

# dist: ## Create distribution package
# 	@./scripts/dist.sh "$(shell cat VERSION)"
# 	@$(MAKE) formula

# release-patch: ## Release a patch version
# 	@$(MAKE) publish NEXT_VERSION=$(shell ./scripts/version.sh patch)

# release-minor: ## Release a minor version
# 	@$(MAKE) publish NEXT_VERSION=$(shell ./scripts/version.sh minor)

# release-major: ## Release a major version
# 	@$(MAKE) publish NEXT_VERSION=$(shell ./scripts/version.sh major)

# man: ## Generate man pages
# 	@./scripts/generate-man.sh

# completions: ## Generate shell completions
# 	@./scripts/generate-completions.sh

# formula: ## Generate Homebrew formula
# 	@./scripts/generate-formula.sh "$(shell cat VERSION)"

.PHONY: all test install lint format clean docs help man background context doctor release-patch release-minor release-major publish dist completions metadata setup formula
