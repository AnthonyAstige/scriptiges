#!/bin/sh

# Get the directory where this script is located.
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Execute eslint-interactive using the helper script from the project root, passing all arguments.
"$SCRIPT_DIR/../run-local-bin.sh" eslint-interactive "$@"
