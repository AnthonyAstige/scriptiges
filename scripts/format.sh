#!/bin/sh

echo "Running 'npx eslint-plugin-astige-format' in the current directory ($(pwd))..."

# Execute the eslint-plugin-astige formatter using npx in the current working directory
# This relies on the consuming project having eslint-plugin-astige available
# or npx being able to fetch it.
npx eslint-plugin-astige-format
