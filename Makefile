.PHONY: all test install lint format clean deep-clean docs help man background context doctor release-patch release-minor release-major publish dist completions metadata setup formula

# Environment setup
SHELL := /bin/sh
PROJECT_ROOT := $(shell pwd)

# Directory structure
SRC_DIR := src
TEST_DIR := tests
TEST_ROOT := tests/root

# Test environment
export PURR_TEST := 1
export PURR_ROOT := $(TEST_ROOT)
export PURR_DATA := $(TEST_ROOT)/.local/share
export PURR_CONFIG := $(TEST_ROOT)/.config
export PURR_CACHE := $(TEST_ROOT)/.cache

include metadata.sh

help: ## Show this help
	@./scripts/help.sh

background: ## Generate project background documentation
	@./scripts/generate-docs.sh background > docs/background.md

setup: ## Setup development environment
	@./scripts/setup.sh

doctor: ## Run developer system checks
	@./scripts/doctor.sh

clean: ## Clean distribution artifacts and development environment
	@./scripts/clean.sh

deep-clean: ## Also clean development dependencies
	@./scripts/deep-clean.sh

test: ## Run all tests
	@./scripts/test.sh

format: ## Format source files
	@shfmt -i 2 -ci -sr -w $(SRC_FILES)

lint: ## Run linting checks
	@shellcheck -x $(SRC_FILES)

publish: ## Publish a release
	@./scripts/publish.sh "$(VERSION)"

dist: ## Create distribution package
	@./scripts/dist.sh "$(shell cat VERSION)"
	@$(MAKE) formula

metadata: ## Update metadata
	@./scripts/metadata.sh

release-patch: ## Release a patch version
	@$(MAKE) publish NEXT_VERSION=$(shell ./scripts/version.sh patch)

release-minor: ## Release a minor version
	@$(MAKE) publish NEXT_VERSION=$(shell ./scripts/version.sh minor)

release-major: ## Release a major version
	@$(MAKE) publish NEXT_VERSION=$(shell ./scripts/version.sh major)

man: ## Generate man pages
	@./scripts/generate-man.sh

completions: ## Generate shell completions
	@./scripts/generate-completions.sh

formula: ## Generate Homebrew formula
	@./scripts/generate-formula.sh "$(shell cat VERSION)"
