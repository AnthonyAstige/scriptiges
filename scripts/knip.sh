#!/bin/sh

# Get the directory where the script is located, resolving symlinks
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# Assume package.json is one level up from the scripts directory
PACKAGE_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
# Path to the knip executable installed in the script's repository
KNIP_EXEC="$PACKAGE_ROOT/node_modules/.bin/knip"

echo "Running Knip (from $PACKAGE_ROOT) in the current directory ($(pwd))..."

# Check if the knip executable exists
if [ ! -x "$KNIP_EXEC" ]; then
  echo "Error: Knip executable not found or not executable at $KNIP_EXEC" >&2
  echo "Please ensure you have run 'npm install' in $PACKAGE_ROOT" >&2
  exit 1
fi

# Execute the specific knip binary directly in the current working directory
# Pass the --no-gitignore flag
"$KNIP_EXEC"

# Check the exit code of knip
KNIP_EXIT_CODE=$?

if [ $KNIP_EXIT_CODE -ne 0 ]; then
  echo "Knip found issues (exit code: $KNIP_EXIT_CODE)." >&2
  # Optionally exit with Knip's exit code to fail CI/CD pipelines
  # exit $KNIP_EXIT_CODE
else
  echo "Knip finished successfully. No issues found."
fi

# Return to the original directory if needed, though usually not necessary for scripts
# cd - > /dev/null
