#!/bin/sh

# Script to run a series of cleanup steps before branch finalization
# Exits on first error encountered and reports the failure

echo "Starting branch cleanup process..."

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Step 1: Formatting
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

# Step 2: Linting (placeholder - you'll need to add a lint.sh script later)
echo "Running linting..."
if ! "$SCRIPT_DIR/lint.sh"; then
  echo "❌ Linting failed! Please fix linting issues before continuing."
  exit 1
fi

# Step 3: Testing (placeholder - you'll need to add a test.sh script later)
echo "Running tests..."
if ! "$SCRIPT_DIR/test.sh"; then
  echo "❌ Tests failed! Please fix test failures before continuing."
  exit 1
fi

echo "✅ All branch cleanup steps completed successfully!"
