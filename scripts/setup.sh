#!/bin/sh

set -euo pipefail

echo "Setting up development environment..."

# Install development dependencies
setup_dependencies() {
    if ! command -v brew >/dev/null; then
        echo "ERROR: Homebrew is required. Please install it first." >&2
        exit 1
    fi

    echo "Installing development dependencies..."
    for pkg in shellcheck shfmt kcov go-md2man shellspec; do
        if ! command -v "$pkg" >/dev/null 2>&1; then
            echo "Installing $pkg..."
            brew install "$pkg"
        fi
    done
}

# Create project structure
setup_directories() {
    echo "Creating project directories..."

    # Source code structure
    mkdir -p src/{bin,lib,completion}
    mkdir -p src/lib/{core,commands,auth,vcs}
    mkdir -p src/lib/commands/{config,keys,status,system}

    # Test directories
    mkdir -p tests/root tests/dist tests/scripts

    # Set permissions
    find src/bin -type f -exec chmod +x {} \;
    find tests -name "*_spec.sh" -type f -exec chmod +x {} \;
}

setup_dependencies
setup_directories

echo "✓ Development environment setup complete"
