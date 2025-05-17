#!/bin/sh

# Script to run a series of cleanup steps before branch finalization
# Exits on first error encountered and reports the failure

echo "Starting audit..."

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Parse command-line arguments
SKIP_BRANCH_REVIEW=false
while [ "$#" -gt 0 ]; do
  case "$1" in
  --skip-branch-review)
    SKIP_BRANCH_REVIEW=true
    shift
    ;;
  *)
    echo "Unknown argument: $1"
    exit 1
    ;;
  esac
done

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

# Step 2: File Case Matching
echo
echo "2) Checking file case matches Git..."
if ! "$SCRIPT_DIR/fileCaseMatchesGit.sh"; then
  echo "❌ File case mismatches found! Please run the suggested git mv commands to fix."
  exit 1
fi

# Step 3: Linting
echo
echo "3) Linting..."
LINT_OUTPUT=$("$SCRIPT_DIR/lint.sh" 2>&1)
LINT_STATUS=$?

if [ $LINT_STATUS -ne 0 ] || [ -n "$LINT_OUTPUT" ]; then
  echo "$LINT_OUTPUT"
  echo "❌ Linting failed! Please fix linting issues (including warnings) before continuing."
  exit 1
fi

# Step 4: Knip (unused exports, etc)
echo
echo "4) Knip analysis..."
if ! "$SCRIPT_DIR/knip.sh"; then
  echo "❌ Knip found issues! Please fix before continuing."
  exit 1
fi

# Step 5: Circular Dependencies
echo
echo "5) Circular Dependency Check..."
if ! "$SCRIPT_DIR/circular-deps.sh"; then
  echo "❌ Circular dependencies found! Please fix before continuing."
  exit 1
fi

# Step 6: Typechecking
echo
echo "6) Typechecking..."
if ! "$SCRIPT_DIR/typecheck.sh"; then
  echo "❌ Typecheck failed! Please fix before continuing."
  exit 1
fi

# Step 7: Unit Tests
echo
echo "7) Running Tests..."
if ! "$SCRIPT_DIR/test.sh"; then
  echo "❌ Tests failed! Please fix test failures before continuing."
  exit 1
fi

echo
echo "🎉 All strict code analysis audits passed!"

# Step 8: AI Diff Review (Optional)
echo
if [ "$SKIP_BRANCH_REVIEW" = true ]; then
  echo "7) Branch review: skipped due to --skip-branch-review option."
else
  echo "8) Branch review..."
  # We don't check the exit code here, as the script itself reports issues
  # and we decided it shouldn't fail the main audit.
  "$SCRIPT_DIR/branch-review.sh"
fi
