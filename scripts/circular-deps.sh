#!/bin/sh

# Script to check for circular dependencies in TypeScript files
# Exits with non-zero code if any circular dependencies are found

echo "Checking for circular dependencies..."

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Run dpdm with our preferred settings
"$SCRIPT_DIR/../run-local-bin.sh" dpdm --no-warning --no-tree --exit-code circular:1 "**/*.ts*"

if [ $? -ne 0 ]; then
  echo "❌ Circular dependencies found! Please fix before continuing."
  exit 1
fi
