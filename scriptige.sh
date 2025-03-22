#!/bin/zsh

COMMAND=$1 # Get the command (first argument)

# List available scripts if no command or help requested
if [ -z "$COMMAND" ] || [ "$COMMAND" = "help" ]; then
  echo "Available scripts:"
  for script in scripts/*.sh; do
    script_name=$(basename "$script" .sh)
    echo "  $script_name"
  done
  exit 0
fi

# Find and execute the requested script
SCRIPT_PATH="scripts/${COMMAND}.sh"

if [ -f "$SCRIPT_PATH" ]; then
  sh "$SCRIPT_PATH"
else
  echo "Error: Script '${COMMAND}' not found"
  echo "Use 'npx krage help' to list available scripts"
  exit 1
fi
