#!/bin/sh

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

COMMAND=$1 # Get the command (first argument)

# List available scripts if no command or help requested
if [ -z "$COMMAND" ] || [ "$COMMAND" = "help" ]; then
  echo "Available scripts:"
  # Find all executable files in scripts directory
  find "$SCRIPT_DIR/scripts" -type f -perm -u+x | while read -r script; do
    script_name=$(basename "$script")
    # Remove any extension for display
    echo "  ${script_name%.*}"
  done | sort
  exit 0
fi

# Find and execute the requested script (with any extension)
SCRIPT_PATH=$(find "$SCRIPT_DIR/scripts" -type f -perm -u+x -name "${COMMAND}.*" | head -n 1)

if [ -n "$SCRIPT_PATH" ]; then
  "$SCRIPT_PATH"
else
  echo "Error: Script '${COMMAND}' not found"
  echo "Use 'npx krage help' to list available scripts"
  exit 1
fi
