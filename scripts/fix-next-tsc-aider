#!/bin/bash

# TODO: Unify with `fix-next-lint.sh` for same syntax

echo "THIS SCRIPT IS UNTESTED, WHEN FIRST USE IT AND CONFIRM ALL GOOD REMOVE THIS echo"

# Run TypeScript compiler with machine-readable output
TSC_OUTPUT=$(npm run tsc -- --pretty false 2>&1)

# Extract the first error message
FIRST_ERROR=$(echo "$TSC_OUTPUT" | grep -m 1 'error TS')

if [ -z "$FIRST_ERROR" ]; then
  echo "No TypeScript errors found."
  exit 0
fi

# Parse error details
# Format: path/to/file.ts(line,col): error TS1234: Error message
FILE_PATH=$(echo "$FIRST_ERROR" | awk -F'(' '{print $1}')
LINE_COL=$(echo "$FIRST_ERROR" | awk -F'[()]' '{print $2}')
ERROR_CODE=$(echo "$FIRST_ERROR" | awk -F': ' '{print $2}' | awk '{print $1}')
ERROR_MESSAGE=$(echo "$FIRST_ERROR" | awk -F': ' '{print $3}')

echo "Running aider to address TypeScript error '$ERROR_CODE: $ERROR_MESSAGE' in '$FILE_PATH' at $LINE_COL"

# Set model flag
MODEL_FLAG=""
if [ -n "$1" ]; then
  MODEL_FLAG="--model $1"
  echo "Using parameter model: $1"
elif ! ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
  echo "No internet connection detected, using local model"
  MODEL_FLAG="--model local"
else
  echo "Using default online model"
fi

aider --yes-always --no-detect-urls --message "Fix TypeScript error $ERROR_CODE: $ERROR_MESSAGE at $LINE_COL" --file "$FILE_PATH" $MODEL_FLAG
