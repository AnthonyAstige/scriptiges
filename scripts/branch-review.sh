#!/bin/sh

# Script to use Aider to review the git diff of the current branch against 'main'.

echo "Starting AI diff review..."

# --- Configuration ---
# You can change the target branch here if needed (e.g., 'master', 'develop')
TARGET_BRANCH="main"
# --- End Configuration ---

# Strong check for any uncommitted changes (staged, unstaged, or untracked)
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Working directory is not clean! Found:"
  git status --short
  echo "Please commit or stash all changes before running branch review."
  exit 1
fi

# Check if aider is installed
if ! command -v aider >/dev/null 2>&1; then
  echo "❌ Aider command not found. Please install Aider (e.g., 'pip install aider-chat') and ensure it's in your PATH."
  exit 1
fi

# Get list of changed files against target branch
CHANGED_FILES=$(git diff --name-only "$TARGET_BRANCH"...HEAD)
DIFF_EXIT_CODE=$?

if [ $DIFF_EXIT_CODE -ne 0 ]; then
  echo "❌ Failed to get changed files against '$TARGET_BRANCH' branch (git diff exit code: $DIFF_EXIT_CODE)."
  exit 1
fi

# Check if any files changed
if [ -z "$CHANGED_FILES" ]; then
  echo "🐥 No files changed compared to '$TARGET_BRANCH' branch. Skipping AI review."
  exit 0
fi

echo "Running Aider for review (this may take a moment)..."

# Construct the prompt for Aider
PROMPT="Please review the following changed files and identify the top 5 most important improvements needed across all files. Focus on:
1. Major opportunities to improve code quality/maintainability
2. Critical issues that could cause bugs or failures
3. Significant performance optimizations

Format your response as a concise markdown list with:
- Priority (High/Medium/Low)
- Description of the issue
- Suggested improvement
- Affected files

Do not make any actual changes to the files. Only list the top 5 most impactful items."

# Pass the changed files to aider for review using the 'free' model
aider --message "$PROMPT" $CHANGED_FILES --no-auto-commits --model branch-review
AIDER_EXIT_CODE=$?

# Reset any accidental Aider file changes (it doens't like to fully listen sometimes)
if [ -n "$(git status --porcelain)" ]; then
  echo "🐥 Looks like Aider changed some stuff, Found:"
  git status --short
  echo "🐥 Cleaning it all up with \`git reset --hard && git clean -fd\`"
  git reset --hard && git clean -fd
fi

if [ $AIDER_EXIT_CODE -ne 0 ]; then
  echo "⚠️ Aider exited with a non-zero exit code ($AIDER_EXIT_CODE). Review its output carefully."
  exit $AIDER_EXIT_CODE
fi

# Get GitHub remote URL and format it for diff view
GIT_REMOTE_URL=$(git remote get-url origin | sed -e 's/^git@github.com:/https:\/\/github.com\//' -e 's/\.git$//')
CURRENT_BRANCH=$(git branch --show-current)
GITHUB_DIFF_URL="${GIT_REMOTE_URL}/compare/${TARGET_BRANCH}...${CURRENT_BRANCH}"

echo
echo "1) Implement AI suggestions where they sense contextual. Re-run for new suggestions until satisfied."
echo "2) Review branch manually at: ${GITHUB_DIFF_URL}"
echo "3) Rebase branch onto origin main via \`npx s rebase\`"

exit 0
