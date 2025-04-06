#!/bin/sh

# Script to run a series of cleanup steps before branch finalization
# Exits on first error encountered and reports the failure

echo "Starting audit..."

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Step 1: Formatting
echo
echo "Running code formatting..."
git diff --quiet --exit-code # Check for existing uncommitted changes
if [ $? -ne 0 ]; then
  echo "❌ Working directory is not clean! Commit or stash changes before running audit."
  exit 1
fi

"$SCRIPT_DIR/format.sh"
if [ $? -ne 0 ]; then
  echo "❌ Formatting failed! Please fix formatting issues before continuing."
  exit 1
fi

git diff --quiet --exit-code
if [ $? -ne 0 ]; then
  echo "❌ Formatting introduced changes! Please review and commit formatting changes before continuing."
  exit 1
fi

# Step 2: Linting
echo
echo "Running linting..."
LINT_OUTPUT=$("$SCRIPT_DIR/lint.sh" 2>&1)
LINT_STATUS=$?

if [ $LINT_STATUS -ne 0 ] || [ -n "$LINT_OUTPUT" ]; then
  echo "$LINT_OUTPUT"
  echo "❌ Linting failed! Please fix linting issues (including warnings) before continuing."
  exit 1
fi

# Step 3: Testing (placeholder - you'll need to add a test.sh script later)
echo
echo "Running typecheck..."
if ! "$SCRIPT_DIR/typecheck.sh"; then
  echo "❌ Typecheck failed! Please fix before continuing."
  exit 1
fi

# Step 4: AI Diff Review (Optional - does not fail audit)
echo
echo "Running AI diff review..."
# We don't check the exit code here, as the script itself reports issues
# and we decided it shouldn't fail the main audit.
"$SCRIPT_DIR/ai-branch-review.sh"

echo
echo "✅ All code audits passed!"
