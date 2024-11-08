.PHONY: all test install lint format clean coverage man doctor publish release-patch release-minor release-major test-dist docs background context test-scripts test-core

SHELL := /bin/sh
PROJECT_ROOT := $(shell pwd)
SRC_DIR := src
TEST_DIR := tests
LIB_DIR := $(SRC_DIR)/lib
BIN_DIR := $(SRC_DIR)/bin
DEV_DIR := tests/dev

TEST_FILES := $(wildcard $(TEST_DIR)/*_spec.sh)
SRC_FILES := $(shell find $(SRC_DIR) -name '*.sh')

export PURR_DEV_MODE := true
export PURR_ROOT := $(PROJECT_ROOT)
export PURR_LIB := $(PURR_ROOT)/src/lib
export PURR_BIN := $(PURR_ROOT)/src/bin
export XDG_CONFIG_HOME := $(DEV_DIR)/.config
export XDG_DATA_HOME := $(DEV_DIR)/.local/share
export XDG_CACHE_HOME := $(DEV_DIR)/.cache

DEBUG ?= 0

DIST_DIR := dist
MAN_DIR := $(DIST_DIR)/man
COMPLETION_DIR := $(DIST_DIR)/completion
TEST_DIST_DIR := tests/dev/dist

include metadata.sh

scripts-executable:
	@[ -d scripts ] && chmod +x scripts/* || true
	@[ -d tests/scripts ] && chmod +x tests/scripts/*_spec.sh || true

setup: scripts-executable
	@./scripts/setup.sh

test: setup test-scripts test-core

test-core:
	@cd tests && SHELLSPEC_LOAD_PATH=. shellspec --shell /bin/bash install_spec.sh make_spec.sh publish_spec.sh

test-scripts:
	@cd tests && SHELLSPEC_LOAD_PATH=. shellspec --shell /bin/bash scripts/*_spec.sh

lint: setup
	shellcheck -x $(SRC_FILES)

format: setup
	shfmt -i 2 -ci -sr -w $(SRC_FILES)

clean:
	rm -rf $(DEV_DIR) $(DIST_DIR)
	git clean -fXd
	@echo "Cleaned development environment"

deep-clean: clean
	brew uninstall shellcheck shfmt kcov go-md2man || true
	@echo "Removed development dependencies"

install: setup
	@echo "Installing purr..."
	@./install

uninstall:
	@echo "Uninstalling purr..."
	@./install uninstall

docs:
	@./scripts/generate-docs.sh

background:
	@./scripts/generate-docs.sh background

context:
	@./scripts/generate-docs.sh context

doctor:
	@./scripts/doctor.sh

release-patch:
	@$(MAKE) publish NEXT_VERSION=$(shell ./scripts/version.sh patch)

release-minor:
	@$(MAKE) publish NEXT_VERSION=$(shell ./scripts/version.sh minor)

release-major:
	@$(MAKE) publish NEXT_VERSION=$(shell ./scripts/version.sh major)

publish:
	@./scripts/publish.sh "$(NEXT_VERSION)"

man: docs/purr.1.md
	@mkdir -p $(MAN_DIR)
	@./scripts/generate-man.sh

completions: docs/purr.1.md
	@mkdir -p $(COMPLETION_DIR)
	@./scripts/completions.sh $< $(COMPLETION_DIR)

test-completions: docs/purr.1.md
	@mkdir -p $(TEST_DIST_DIR)/completion
	@./scripts/completions.sh $< $(TEST_DIST_DIR)/completion

coverage: setup
	@./scripts/coverage.sh

dist:
	@./scripts/dist.sh "$(shell cat VERSION)" "release"

test-dist:
	@./scripts/dist.sh "$(shell cat VERSION)" "test"
