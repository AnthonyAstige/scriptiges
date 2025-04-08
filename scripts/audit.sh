#!/bin/sh

# Script to run a series of cleanup steps before branch finalization
# Exits on first error encountered and reports the failure

echo "Starting audit..."

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Step 1: Formatting
echo
echo "1) Formatting..."
# Strong check for any uncommitted changes (staged, unstaged, or untracked)
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Working directory is not clean! Found:"
  git status --short
  echo "Please commit or stash all changes before running audit."
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
echo "2) Linting..."
LINT_OUTPUT=$("$SCRIPT_DIR/lint.sh" 2>&1)
LINT_STATUS=$?

if [ $LINT_STATUS -ne 0 ] || [ -n "$LINT_OUTPUT" ]; then
  echo "$LINT_OUTPUT"
  echo "❌ Linting failed! Please fix linting issues (including warnings) before continuing."
  exit 1
fi

# Step 3: Knip (unused exports, etc)
echo
echo "3) Knip analysis..."
if ! "$SCRIPT_DIR/knip.sh"; then
  echo "❌ Knip found issues! Please fix before continuing."
  exit 1
fi

# Step 4: Circular Dependencies
echo
echo "4) Circular Dependency Check..."
if ! "$SCRIPT_DIR/circular-deps.sh"; then
  echo "❌ Circular dependencies found! Please fix before continuing."
  exit 1
fi

# Step 5: Typechecking
echo
echo "5) Typechecking..."
if ! "$SCRIPT_DIR/typecheck.sh"; then
  echo "❌ Typecheck failed! Please fix before continuing."
  exit 1
fi

# Step 6: Unit Tests
echo
echo "6) Running Tests..."
if ! "$SCRIPT_DIR/test.sh"; then
  echo "❌ Tests failed! Please fix test failures before continuing."
  exit 1
fi

echo
echo "🎉 All strict code analysis audits passed!"

# Step 7: AI Diff Review (Optional - does not fail audit)
echo
echo "7) Final Step: Branch review..."
# We don't check the exit code here, as the script itself reports issues
# and we decided it shouldn't fail the main audit.
"$SCRIPT_DIR/branch-review.sh"
