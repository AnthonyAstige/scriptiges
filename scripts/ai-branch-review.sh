#!/bin/sh

# Script to use Aider to review the git diff of the current branch against 'main'.

echo "Starting AI diff review..."

# --- Configuration ---
# You can change the target branch here if needed (e.g., 'master', 'develop')
TARGET_BRANCH="main"
# --- End Configuration ---

# Check if aider is installed
if ! command -v aider >/dev/null 2>&1; then
  echo "❌ Aider command not found. Please install Aider (e.g., 'pip install aider-chat') and ensure it's in your PATH."
  # Exit non-zero because the script cannot perform its function.
  exit 1
fi

# Get the diff against the target branch
# Using TARGET_BRANCH...HEAD includes changes on the current branch since it diverged from TARGET_BRANCH
DIFF_CONTENT=$(git diff "$TARGET_BRANCH"...HEAD)
DIFF_EXIT_CODE=$?

if [ $DIFF_EXIT_CODE -ne 0 ]; then
  echo "❌ Failed to generate diff against '$TARGET_BRANCH' branch (git diff exit code: $DIFF_EXIT_CODE)."
  # Exit non-zero as we couldn't get the diff needed for review.
  exit 1
fi

# Check if diff is empty
if [ -z "$DIFF_CONTENT" ]; then
  echo "✅ No changes detected compared to '$TARGET_BRANCH' branch. Skipping AI review."
  exit 0
fi

echo "Running Aider for review (this may take a moment)..."

# Construct the prompt for Aider
# Instructs Aider to review the diff from stdin, list top 3 improvements in a table, and explicitly NOT edit files.
PROMPT="Please review the following git diff provided via standard input. Identify the top 3 most important areas for potential improvement based on code quality, clarity, and best practices. Present your findings concisely in a markdown table format with columns like 'Priority', 'File(s)', and 'Suggestion'. Do *not* propose any code changes, do *not* ask to apply edits, and do *not* modify any files. Just output the review table."

# Pipe the diff content to aider and provide the prompt via --message
# --no-auto-commits prevents aider from automatically committing any (unintended) changes.
# We rely heavily on the prompt to prevent edits. Aider's primary function is editing,
# so this usage is somewhat off-label, but feasible with careful prompting.
echo "$DIFF_CONTENT" | aider --message "$PROMPT" --no-auto-commits

AIDER_EXIT_CODE=$?

if [ $AIDER_EXIT_CODE -ne 0 ]; then
  echo "⚠️ Aider exited with a non-zero exit code ($AIDER_EXIT_CODE). Review its output carefully."
  exit $AIDER_EXIT_CODE
fi

exit 0
