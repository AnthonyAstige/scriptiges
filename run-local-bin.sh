#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if at least one argument (the command to run) is provided.
if [ $# -eq 0 ]; then
  echo "Usage: $0 <command> [args...]" >&2
  exit 1
fi

COMMAND_NAME="$1"
# Shift the arguments so that "$@" now contains only the arguments for the command.
shift

# Assume the script is run from the repository root.
REPO_ROOT="."
# Construct the path to the executable relative to the repository root.
EXEC_PATH="$REPO_ROOT/node_modules/.bin/$COMMAND_NAME"

# Check if the executable exists and is executable.
if [ ! -x "$EXEC_PATH" ]; then
  echo "Error: Executable '$COMMAND_NAME' not found or not executable at $EXEC_PATH" >&2
  echo "Please ensure you have run 'npm install' or 'yarn install' in the repository root ($REPO_ROOT)" >&2
  exit 1
fi

# Execute the command with its arguments.
"$EXEC_PATH" "$@"

# The script will exit with the exit code of the executed command due to 'set -e'.
