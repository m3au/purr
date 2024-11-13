#!/bin/sh

set -e

echo "Linting shell scripts..."

# Find all shell scripts
src_files=$(find src -type f -name "*.sh")
test_files=$(find tests -type f -name "*_spec.sh")
script_files=$(find scripts -type f -name "*.sh")

# Display files being checked
echo "Source files:"
printf '%s\n' "$src_files" | printf '  %s\n' "$(cat)"
echo "Test files:"
printf '%s\n' "$test_files" | printf '  %s\n' "$(cat)"
echo "Script files:"
printf '%s\n' "$script_files" | printf '  %s\n' "$(cat)"

# Run shellcheck
printf '\nRunning shellcheck...\n'
shellcheck -x "$src_files" "$test_files" "$script_files"
echo "✓ All files passed shellcheck"
