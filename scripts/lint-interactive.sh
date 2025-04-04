#!/bin/sh

# Get the directory where this script is located.
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Execute eslint-interactive using the helper script, passing all arguments.
"$SCRIPT_DIR/internal/run-local-bin.sh" eslint-interactive "$@"
