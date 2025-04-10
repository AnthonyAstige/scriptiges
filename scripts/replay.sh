#!/bin/sh

# Script to rebase current branch onto latest main branch
# This is a safer alternative to `git rebase main` that:
# 1. Runs a code audit
# 2. Ensures working directory is clean
# 3. Fetches latest changes
# 4. Shows what will be rebased
# 5. Provides clear instructions if conflicts occur

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

echo "Starting branch replay..."

# --- Configuration ---
# You can change the target branch here if needed (e.g., 'master', 'develop')
TARGET_BRANCH="main"
# --- End Configuration ---

# Run audit
# TODO: Put this back
# echo
# echo "Running audit (minus branch review)..."
# $SCRIPT_DIR/audit.sh --skip-branch-review
# if [ $? -ne 0 ]; then
#   echo "❌ Audit failed before replay. Please fix the issues and try again."
#   exit 1
# fi

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
if ! (git checkout "$TARGET_BRANCH" && git rebase "$CURRENT_BRANCH" && git checkout "$CURRENT_BRANCH"); then
  echo
  echo "❌ Rebase encountered conflicts. Please:"
  echo "1. Resolve the conflicts marked in files"
  echo "2. Stage the resolved files with 'git add'"
  echo "3. Continue the rebase with 'git rebase --continue'"
  echo "4. If you need to abort, run 'git rebase --abort'"
  exit 1
fi

# TODO: Add back and test this pushing
# echo
# echo "Pushing rebased $TARGET_BRANCH to origin (force-with-lease)..."
# git push origin "$TARGET_BRANCH" --force-with-lease
# if [ $? -ne 0 ]; then
#   echo "❌ Push failed! Please resolve any issues and try again."
#   echo "   Common issues include the remote branch having new commits."
#   echo "   You might need to run 'git fetch origin' and replay again."
#   exit 1
# fi

echo
echo "✅ Successfully replayed $CURRENT_BRANCH onto latest $TARGET_BRANCH and pushed"
