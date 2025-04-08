#!/bin/sh

# Runs tests using the host repository's jest installation
# This ensures we respect any custom jest configurations in the host repo

# TODO: Test if this works on a repo with real jest tests
echo "Running tests (if npm script \`test\` is present)..."
npm run test --if-present

if [ $? -ne 0 ]; then
  echo "❌ Tests failed! Please fix test failures before continuing."
  exit 1
fi
