#!/bin/sh

# Get the directory where this script is located.
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

echo "Running Knip in the current directory ($(pwd))..."

# Execute knip using the helper script, passing its specific arguments.
# Note: The helper script handles finding the executable and error checking.
"$SCRIPT_DIR/run-local-bin.sh" knip -c "./node_modules/scriptiges/knip.json" "$@"
