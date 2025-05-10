#!/bin/bash

# Validate first argument
if [[ $# -eq 0 ]]; then
  echo "Error: Missing required action parameter"
  echo "Usage: fix-lint-aider-next <aider|vim> [options] [model]"
  exit 1
fi

ACTION=$1
if [[ "$ACTION" != "aider" && "$ACTION" != "vim" ]]; then
  echo "Error: Invalid action '$ACTION'. Must be 'aider' or 'vim'"
  exit 1
fi
shift

# Parse remaining arguments
RULE_ID=""
WARNING_COUNT=10000
LOOP_MODE=false
HELP_MODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
  --help)
    HELP_MODE=true
    shift # past argument
    ;;
  --loop)
    LOOP_MODE=true
    shift # past argument
    ;;
  --ruleId)
    RULE_ID="$2"
    shift # past argument
    shift # past value
    ;;
  --include-warnings)
    WARNING_COUNT=0
    shift # past argument
    ;;
  --model)
    MODEL_FLAG="--model $2"
    shift # past argument
    shift # past value
    ;;
  *)
    echo "Error: Unknown argument '$1'"
    exit 1
    ;;
  esac
done

if [ "$HELP_MODE" = true ]; then
  echo "Usage: fix-lint-aider-next <aider|vim> [options] [model]"
  echo
  echo "Options:"
  echo "  --help               Show this help message and exit"
  echo "  --loop               Continue fixing lint issues until all are resolved"
  echo "  --ruleId RULE_ID     Only fix issues matching the specified ESLint rule ID"
  echo "  --include-warnings   Include warnings in addition to errors (default: errors only)"
  echo "  --model MODEL        Specify the model to use with aider (default: default)"
  echo
  echo "Arguments:"
  echo "  model                Optional model name to use with aider (see ~/.aider.conf.yml for aliases)"
  exit 0
fi

while true; do
  # Run Next.js linter and output results in JSON format
  # TODO: Get back to eslint_d caching, etc
  # LINT_RESULTS=$(npx eslint_d --cache --config ./eslint.config.ts --format json 2>/dev/null)
  LINT_RESULTS=$(npx eslint --format json 2>/dev/null)

  echo "**SEARCHING**"
  # Filter results by error/warning count and optionally by rule ID
  if [ -n "$RULE_ID" ]; then
    echo "Rule: $RULE_ID"
    LINT_RESULTS=$(echo "$LINT_RESULTS" | jq --arg ruleId "$RULE_ID" --argjson warningCount "$WARNING_COUNT" '[.[] | select((.errorCount > 0 or .warningCount > $warningCount) and (.messages | any(.ruleId == $ruleId)))]')
  else
    echo "Rules: [ALL]"
    LINT_RESULTS=$(echo "$LINT_RESULTS" | jq --argjson warningCount "$WARNING_COUNT" '[.[] | select(.errorCount > 0 or .warningCount > $warningCount)]')
  fi

  if [ "$WARNING_COUNT" -eq 0 ]; then
    echo "Warnings: Yes"
  else
    echo "Warnings: No"
  fi

  # Parse the first lint message using jq
  if [ -n "$RULE_ID" ]; then
    FIRST_LINT_MESSAGE=$(echo "$LINT_RESULTS" | jq -r --arg ruleId "$RULE_ID" --argjson warningCount "$WARNING_COUNT" '
  [
    .[]
    | select((.errorCount > 0 or .warningCount > $warningCount) and (.messages | any(.ruleId == $ruleId)))
    | {filePath, message: (.messages[] | select(.ruleId == $ruleId))}
    | select(.message != null)
  ]
  | .[0]
')
  else
    FIRST_LINT_MESSAGE=$(echo "$LINT_RESULTS" | jq -r --argjson warningCount "$WARNING_COUNT" '
  [
    .[]
    | select(.errorCount > 0 or .warningCount > $warningCount)
    | {filePath, message: (.messages[0])}
  ]
  | .[0]
')
  fi
  if [ -z "$FIRST_LINT_MESSAGE" ] || [ "$FIRST_LINT_MESSAGE" = "null" ]; then
    echo
    echo "**EXITING**"
    echo "No issues found."
    if [ "$WARNING_COUNT" -ne 0 ]; then
      echo
      echo "Try running with --include-warnings to also fix warnings."
    fi
    exit 0
  fi

  # Extract the file path and message from the JSON object
  FILE_PATH=$(echo "$FIRST_LINT_MESSAGE" | jq -r '.filePath')
  MESSAGE=$(echo "$FIRST_LINT_MESSAGE" | jq -r '.message')

  echo
  echo "**FOUND**"
  echo "File: '$FILE_PATH'"
  echo "Lint Message:"
  echo $MESSAGE | jq
  echo

  # Set default model if not specified
  if [ -z "$MODEL_FLAG" ]; then
    MODEL_FLAG="--model default"
    if ! ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
      MODEL_FLAG="--model local"
    fi
  fi

  echo
  echo "**RUNNING**"
  if [ "$ACTION" = "vim" ]; then
    echo "Opening in neovim: $FILE_PATH"
    nvim -u ~/.config/nvim/init.lua "$FILE_PATH"
  else
    echo "aider $MODEL_FLAG # And other params"
    aider --yes-always --no-detect-urls --message "Fix lint message: $MESSAGE" --file "$FILE_PATH" $MODEL_FLAG
  fi
  # Break the loop if not in LOOP_MODE
  if [ "$LOOP_MODE" = false ]; then
    break
  else
    echo
    echo "**LOOPING** (--loop)"
    echo "Continuing until lint issues exhausted"
    echo
  fi
done
