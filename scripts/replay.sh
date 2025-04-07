#!/bin/sh

# Script to rebase current branch onto latest main branch
# This is a safer alternative to `git rebase main` that:
# 1. Ensures working directory is clean
# 2. Fetches latest changes
# 3. Shows what will be rebased
# 4. Provides clear instructions if conflicts occur

echo "Starting branch replay..."

# --- Configuration ---
# You can change the target branch here if needed (e.g., 'master', 'develop')
TARGET_BRANCH="main"
# --- End Configuration ---

# Strong check for any uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Working directory is not clean! Found:"
  git status --short
  echo "Please commit or stash all changes before replaying."
  exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "$TARGET_BRANCH" ]; then
  echo "❌ You're already on the $TARGET_BRANCH branch. Switch to your feature branch first."
  exit 1
fi

echo "Fetching latest changes from origin..."
git fetch origin

echo
echo "Replaying $CURRENT_BRANCH onto latest $TARGET_BRANCH..."
echo "The following commits will be replayed:"
git --no-pager log --oneline --graph "$TARGET_BRANCH".."$CURRENT_BRANCH"

echo
echo "Starting rebase..."
if ! git rebase "$TARGET_BRANCH"; then
  echo
  echo "❌ Rebase encountered conflicts. Please:"
  echo "1. Resolve the conflicts marked in files"
  echo "2. Stage the resolved files with 'git add'"
  echo "3. Continue the rebase with 'git rebase --continue'"
  echo "4. If you need to abort, run 'git rebase --abort'"
  exit 1
fi

echo
echo "✅ Successfully replayed $CURRENT_BRANCH onto latest $TARGET_BRANCH!"
echo "You may need to force push with: git push --force-with-lease"
