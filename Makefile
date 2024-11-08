.PHONY: all test install lint format clean coverage man doctor publish release-patch release-minor release-major test-dist

SHELL := /bin/sh
PROJECT_ROOT := $(shell pwd)
SRC_DIR := src
TEST_DIR := tests
LIB_DIR := $(SRC_DIR)/lib
BIN_DIR := $(SRC_DIR)/bin
DEV_DIR := tests/dev

TEST_FILES := $(wildcard $(TEST_DIR)/*.spec)
SRC_FILES := $(shell find $(SRC_DIR) -name '*.sh')

export PURR_DEV_MODE := true
export PURR_ROOT := $(PROJECT_ROOT)
export PURR_LIB := $(PURR_ROOT)/src/lib
export PURR_BIN := $(PURR_ROOT)/src/bin
export XDG_CONFIG_HOME := $(DEV_DIR)/.config
export XDG_DATA_HOME := $(DEV_DIR)/.local/share
export XDG_CACHE_HOME := $(DEV_DIR)/.cache

# Add debug control
DEBUG ?= 0

# [x] Test if it works
setup: $(DEV_DIR)
	@if [ "$(DEBUG)" = "1" ]; then \
		echo "Setting up development environment..."; \
		echo "Environment variables set:"; \
		echo "  PURR_DEV_MODE=$(PURR_DEV_MODE)"; \
		echo "  PURR_ROOT=$(PURR_ROOT)"; \
		echo "  PURR_LIB=$(PURR_LIB)"; \
		echo "  PURR_BIN=$(PURR_BIN)"; \
		echo "  XDG_CONFIG_HOME=$(XDG_CONFIG_HOME)"; \
		echo "  XDG_DATA_HOME=$(XDG_DATA_HOME)"; \
		echo "  XDG_CACHE_HOME=$(XDG_CACHE_HOME)"; \
	fi
	@command -v shellcheck >/dev/null || brew install shellcheck
	@command -v shfmt >/dev/null || brew install shfmt
	@command -v kcov >/dev/null || brew install kcov
	@command -v go-md2man >/dev/null || brew install go-md2man
	@command -v shellspec >/dev/null || brew install shellspec

$(DEV_DIR):
	@if [ "$(DEBUG)" = "1" ]; then \
		mkdir -pv $(DEV_DIR)/.config/purr; \
		mkdir -pv $(DEV_DIR)/.local/share/purr/backups; \
		mkdir -pv $(DEV_DIR)/.cache/purr; \
		mkdir -pv $(DEV_DIR)/.local/share/zsh/site-functions; \
		mkdir -pv $(DEV_DIR)/dist; \
		chmod -v +x $(TEST_DIR)/*.spec; \
		[ -d "$(BIN_DIR)" ] && chmod -v +x $(BIN_DIR)/* || true; \
	else \
		mkdir -p $(DEV_DIR)/.config/purr; \
		mkdir -p $(DEV_DIR)/.local/share/purr/backups; \
		mkdir -p $(DEV_DIR)/.cache/purr; \
		mkdir -p $(DEV_DIR)/.local/share/zsh/site-functions; \
		mkdir -p $(DEV_DIR)/dist; \
		chmod +x $(TEST_DIR)/*.spec; \
		[ -d "$(BIN_DIR)" ] && chmod +x $(BIN_DIR)/* || true; \
	fi

# [x] Test if it works
test: setup
	@[ "$(DEBUG)" = "1" ] && echo "Running tests..." || true
	@cd tests && SHELLSPEC_LOAD_PATH=. shellspec --shell /bin/bash *.spec

lint: setup
	shellcheck -x $(SRC_FILES)

format: setup
	shfmt -i 2 -ci -sr -w $(SRC_FILES)

man: docs/purr.1.md
	go-md2man -in $< -out docs/purr.1

clean:
	rm -rf $(DEV_DIR)
	git clean -fXd
	@echo "Cleaned development environment"

# [x] Test if it works
deep-clean: clean
	brew uninstall shellcheck shfmt kcov go-md2man || true
	@echo "Removed development dependencies"

install: setup ## Install purr
	@echo "Installing purr..."
	@./install

uninstall: ## Uninstall purr
	@echo "Uninstalling purr..."
	@./install uninstall

DOCS_DIR := docs
BACKGROUND_MD := $(DOCS_DIR)/background.md
CONTEXT_MD := $(DOCS_DIR)/context.md

background: $(BACKGROUND_MD)
	@echo "Generating background documentation..."

$(BACKGROUND_MD):
	@{ \
		echo "# Project Context"; \
		echo "Generated: $$(date)"; \
		echo "## About This Document"; \
		echo "This document provides:"; \
		echo "- Project rules and conventions"; \
		echo "- File structure and organization"; \
		echo "- Module dependencies and relationships"; \
		echo "- Command and data flows"; \
		echo "## Target Audience"; \
		echo "purr is designed for developers and technical professionals who use macOS and Unix-like systems. It is particularly suited for those who rely on 1Password for secure key management, GPG for signing commits, and SSH for secure connections. This tool is ideal for users who prioritize security and efficiency in their development workflows."; \
		echo "## Project Rules"; \
		echo "This project is POSIX-compliant and should work on any POSIX-compliant system."; \
		echo "1. No whitespace-only changes"; \
		echo "2. No hallucinated code/comments"; \
		echo "3. Follow XDG Base Directory Specification"; \
		echo "4. Maintain test coverage"; \
		echo "5. Use shellcheck for linting"; \
		echo "6. Keep modules focused and small"; \
		echo "7. Use common functions for output"; \
		echo "8. Proper error handling and exit codes"; \
		echo "9. Secure handling of sensitive data"; \
		echo "10. Consistent style and formatting"; \
		echo "11. Don't add comments to the code at all"; \
		echo "## Project Structure"; \
		echo "\`\`\`"; \
		tree -I 'node_modules|coverage|.git'; \
		echo "\`\`\`"; \
		echo "## Core Modules"; \
		for file in src/lib/core/*.sh; do \
			name=$$(basename "$$file"); \
			desc=$$(head -n 3 "$$file" | grep -v '^#!' | grep '^#' | sed 's/^#//' || echo "No description"); \
			echo "- **$$name**:$$desc"; \
		done; \
		echo "## Command Modules"; \
		find src/lib/commands -name "*.sh" | while read -r file; do \
			name=$$(basename "$$file"); \
			dir=$$(dirname "$$file" | sed 's|src/lib/commands/||'); \
			desc=$$(head -n 3 "$$file" | grep -v '^#!' | grep '^#' | sed 's/^#//' || echo "No description"); \
			echo "- **$$dir/$$name**:$$desc"; \
		done; \
		echo "## File Purposes"; \
		echo "- src/bin/purr: Main executable entry point"; \
		echo "- src/lib/core/: Core functionality modules"; \
		echo "- src/lib/commands/: Command implementation modules"; \
		echo "- src/completion/: Shell completion scripts"; \
		echo "- tests/: Test files for each module"; \
		echo "- docs/: Documentation and man pages"; \
	} > $@
	@echo "Background documentation generated at $(BACKGROUND_MD)"

context: $(CONTEXT_MD)
	@echo "Generating context documentation..."

$(CONTEXT_MD):
	@{ \
		echo "# Project Status"; \
		echo "Generated: $$(date)"; \
		echo "## About This Document"; \
		echo "This document provides:"; \
		echo "- A list of TODOs, FIXMEs, and XXXs from the source files"; \
		echo "- Important notes for developers"; \
		echo "- Environment variables used in the project"; \
		echo "- Required and optional dependencies"; \
		echo "- Available commands"; \
		echo "## TODO and Workdesk"; \
		echo "This section lists all the TODOs, FIXMEs, and XXXs found in the source files."; \
		find . -type f -not -path "*/\.*" -not -path "*/node_modules/*" -exec grep -l "TODO\|FIXME\|XXX" {} \; | while read -r file; do \
			if [ -f "$$file" ]; then \
				echo "### $$(basename "$$file")"; \
				grep -h "TODO\|FIXME\|XXX" "$$file" | sed 's/^.*TODO/- [ ]/' | sed 's/^.*FIXME/- [ ]/' | sed 's/^.*XXX/- [ ]/'; \
			fi; \
		done; \
		echo "## Notes"; \
		echo "- Remember to maintain test coverage while developing"; \
		echo "- Keep security as top priority"; \
		echo "- Document all shell compatibility issues"; \
		echo "- Track performance impacts"; \
		echo "- Keep installation footprint minimal"; \
		echo "## Environment Variables"; \
		echo "Core:"; \
		grep -h "^[[:space:]]*export[[:space:]]\+PURR_" src/lib/core/*.sh | sed 's/^.*export //' | sed 's/=.*//' | sort -u | while read -r var; do \
			echo "- $$var"; \
		done; \
		echo "Runtime:"; \
		echo "- SSH_AUTH_SOCK: SSH agent socket"; \
		echo "- GPG_TTY: GPG terminal"; \
		echo "- SHELL: User's shell"; \
		echo "## Dependencies"; \
		echo "Required:"; \
		echo "- 1Password CLI (op)"; \
		echo "- SSH"; \
		echo "- GPG"; \
		echo "- Git"; \
		echo "Optional:"; \
		echo "- lolcat (for fancy output)"; \
		echo "- shellcheck (for development)"; \
		echo "- kcov (for test coverage)"; \
		echo "## Available Commands"; \
		echo "System Commands:"; \
		echo "- install: Install or reinstall purr"; \
		echo "- uninstall: Remove purr"; \
		echo "- update: Check for and install updates"; \
		echo "- verify: Verify installation"; \
		echo "- version: Show version information"; \
		echo "- doctor: Run system diagnostics"; \
		echo "- lock: Unload keys and lock agents"; \
		echo "Status Commands:"; \
		echo "- status: Show current status"; \
		echo "Keys Commands:"; \
		echo "- keys: Manage SSH and GPG keys"; \
		echo "Config Commands:"; \
		echo "- config: Manage configuration"; \
		echo "- reset: Reset to defaults"; \
		echo "- backup: Backup configuration"; \
		echo "Help Commands:"; \
		echo "- help: Show help message"; \
	} > $@
	@echo "Context documentation generated at $(CONTEXT_MD)"

doctor:
	@echo "Checking development environment..."
	@echo "- Directory structure:"
	@[ -d "$(DEV_DIR)/.config/purr" ] && echo "✓ Config directory exists" || echo "✗ Missing config directory"
	@[ -d "$(DEV_DIR)/.local/share/purr/backups" ] && echo "✓ Data directory exists" || echo "✗ Missing data directory"
	@[ -d "$(DEV_DIR)/.cache/purr" ] && echo "✓ Cache directory exists" || echo "✗ Missing cache directory"
	@echo "- Development dependencies:"
	@command -v shellcheck >/dev/null && echo "✓ shellcheck installed" || echo "✗ shellcheck missing"
	@command -v shfmt >/dev/null && echo "✓ shfmt installed" || echo "✗ shfmt missing"
	@command -v kcov >/dev/null && echo "✓ kcov installed" || echo "✗ kcov missing"
	@command -v go-md2man >/dev/null && echo "✓ go-md2man installed" || echo "✗ go-md2man missing"
	@echo "- File permissions:"
	@find "$(TEST_DIR)" -name "*.spec" -perm +111 -print | grep -q . && echo "✓ Test files are executable" || echo "✗ Test files not executable"
	@[ -d "$(BIN_DIR)" ] && find "$(BIN_DIR)" -type f -perm +111 -print | grep -q . && echo "✓ Binary files are executable" || echo "✗ Binary files not executable"
	@echo "- Environment variables:"
	@[ "$(PURR_DEV_MODE)" = "true" ] && echo "✓ PURR_DEV_MODE is set" || echo "✗ PURR_DEV_MODE not set"
	@[ -n "$(PURR_ROOT)" ] && echo "✓ PURR_ROOT is set" || echo "✗ PURR_ROOT not set"
	@[ -n "$(PURR_LIB)" ] && echo "✓ PURR_LIB is set" || echo "✗ PURR_LIB not set"
	@[ -n "$(PURR_BIN)" ] && echo "✓ PURR_BIN is set" || echo "✗ PURR_BIN not set"
	@[ -n "$(XDG_CONFIG_HOME)" ] && echo "✓ XDG_CONFIG_HOME is set" || echo "✗ XDG_CONFIG_HOME not set"
	@[ -n "$(XDG_DATA_HOME)" ] && echo "✓ XDG_DATA_HOME is set" || echo "✗ XDG_DATA_HOME not set"
	@[ -n "$(XDG_CACHE_HOME)" ] && echo "✓ XDG_CACHE_HOME is set" || echo "✗ XDG_CACHE_HOME not set"

# Version management
CURRENT_VERSION ?= $(shell cat VERSION 2>/dev/null || echo "0.0.0")
NEXT_VERSION ?= $(shell echo $(CURRENT_VERSION) | awk -F. '{$$NF = $$NF + 1;} 1' | sed 's/ /./g')

# Publishing targets
publish: ## Create a new release
	@echo "Publishing version $(NEXT_VERSION)..."
	@echo "$(NEXT_VERSION)" > VERSION
	@$(MAKE) dist
	@if [ "${SKIP_GIT:-0}" = "0" ]; then \
		git add VERSION dist/purr-$(NEXT_VERSION).tar.gz; \
		git commit -m "Release v$(NEXT_VERSION)"; \
		git tag -a "v$(NEXT_VERSION)" -m "Release v$(NEXT_VERSION)"; \
	fi
	@if [ "${SKIP_TEST:-0}" = "0" ]; then \
		$(MAKE) test test-dist; \
	fi
	@echo "✨ Published v$(NEXT_VERSION)"

dist: clean ## Create distribution archive
	@echo "Creating distribution archive..."
	@mkdir -p dist/purr-$(CURRENT_VERSION)
	@cp -r src LICENSE README.md VERSION install dist/purr-$(CURRENT_VERSION)/
	@cd dist && tar czf purr-$(CURRENT_VERSION).tar.gz purr-$(CURRENT_VERSION)
	@rm -rf dist/purr-$(CURRENT_VERSION)

release-patch: ## Increment patch version (0.0.X)
	@$(MAKE) publish NEXT_VERSION=$(shell echo $(CURRENT_VERSION) | awk -F. '{$$NF = $$NF + 1;} 1' | sed 's/ /./g')

release-minor: ## Increment minor version (0.X.0)
	@$(MAKE) publish NEXT_VERSION=$(shell echo $(CURRENT_VERSION) | awk -F. '{$$2 = $$2 + 1; $$3 = 0;} 1' | sed 's/ /./g')

release-major: ## Increment major version (X.0.0)
	@$(MAKE) publish NEXT_VERSION=$(shell echo $(CURRENT_VERSION) | awk -F. '{$$1 = $$1 + 1; $$2 = 0; $$3 = 0;} 1' | sed 's/ /./g')

test-dist: ## Create test distribution archive
	@echo "Creating test distribution archive..."
	@mkdir -p $(DEV_DIR)/dist/purr-test
	@cp -r src LICENSE README.md VERSION install $(DEV_DIR)/dist/purr-test/
	@cd $(DEV_DIR)/dist && tar czf purr-test.tar.gz purr-test
	@rm -rf $(DEV_DIR)/dist/purr-test
