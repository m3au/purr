#!/bin/sh

set -e

echo "Setting up development environment..."

# Install development dependencies
echo "Installing development dependencies..."

# Check if brew is available
if ! command -v brew >/dev/null; then
  echo "Error: Homebrew is required but not installed"
  exit 1
fi

# Install required development tools
dev_packages="shellcheck shfmt kcov go-md2man shellspec"

for pkg in $dev_packages; do
  if ! command -v "$pkg" >/dev/null; then
    echo "Installing $pkg..."
    brew install "$pkg"
  fi
done

# Create project directories
echo "Creating project directories..."

# Create test directories without brace expansion
mkdir -p tests/root/.config/purr
mkdir -p tests/root/.local/share/purr
mkdir -p tests/root/.cache/purr
mkdir -p tests/dist

# Set permissions
chmod -R 755 tests/root 2>/dev/null || true

echo "✓ Development environment setup complete"
