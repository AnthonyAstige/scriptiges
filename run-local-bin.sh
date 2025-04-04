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

# Get the directory where this script is located.
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# Get the scriptiges project root (which is the directory this script is in)
PACKAGE_ROOT="$SCRIPT_DIR"
# Construct the path to the executable.
EXEC_PATH="$PACKAGE_ROOT/node_modules/.bin/$COMMAND_NAME"

# Check if the executable exists and is executable.
if [ ! -x "$EXEC_PATH" ]; then
  echo "Error: Executable '$COMMAND_NAME' not found or not executable at $EXEC_PATH" >&2
  echo "Please ensure you have run 'npm install' or 'yarn install' in $PACKAGE_ROOT" >&2
  exit 1
fi

# Execute the command with its arguments.
"$EXEC_PATH" "$@"

# The script will exit with the exit code of the executed command due to 'set -e'.
