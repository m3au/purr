#!/bin/sh

set -e

echo "Checking development environment..."

# Check development dependencies
echo "- Development dependencies:"
dev_packages="shellcheck shfmt kcov go-md2man shellspec"

for pkg in $dev_packages; do
  if command -v "$pkg" >/dev/null; then
    echo "✓ $pkg installed"
  else
    echo "✗ $pkg not installed"
    has_missing_deps=1
  fi
done

if [ "${has_missing_deps:-0}" = "1" ]; then
  echo "Run 'make dev-setup' to install missing dependencies"
fi

# Check directory structure
echo "- Directory structure:"
required_dirs="
    tests/root/.config/purr
    tests/root/.local/share/purr
    tests/root/.cache/purr
    tests/dist
"

for dir in $required_dirs; do
  if [ -d "$dir" ]; then
    echo "✓ Found directory: $dir"
  else
    echo "✗ Missing directory: $dir"
    has_missing_dirs=1
  fi
done

if [ "${has_missing_dirs:-0}" = "1" ]; then
  echo "Run 'make dev-setup' to create missing directories"
fi

# Check file permissions
echo "- File permissions:"
if find tests -type f -name "*_spec.sh" -exec test -x {} \; >/dev/null 2>&1; then
  echo "✓ Test files are executable"
else
  echo "✗ Some test files are not executable"
fi

if find src/bin -type f -exec test -x {} \; >/dev/null 2>&1; then
  echo "✓ Binary files are executable"
else
  echo "✗ Some binary files are not executable"
fi

# Check environment variables
echo "- Environment variables:"
check_env() {
  var_name="$1"
  var_value="$2"

  if [ -n "$var_value" ]; then
    echo "✓ $var_name set to: $var_value"
  else
    echo "✗ $var_name not set"
  fi
}

check_env "PURR_ROOT" "$PURR_ROOT"
check_env "PURR_LIB" "$PURR_LIB"
check_env "PURR_BIN" "$PURR_BIN"
