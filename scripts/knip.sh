#!/bin/sh
set -e

# Directory that contains this helper script (usually scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Work from the directory the user called the script in (the repo root)
REPO_DIR="$(pwd)"

echo "Running Knip in the current directory ($REPO_DIR)…"

# Prefer repo-specific config
if [ -f "./knip.config.ts" ]; then
  echo "→ Using repo-specific Knip config: ./knip.config.ts"
  "$SCRIPT_DIR/../run-local-bin.sh" knip "$@"
else
  echo "→ Using fallback Knip config: ./node_modules/scriptiges/knip.config.ts"
  "$SCRIPT_DIR/../run-local-bin.sh" knip -c "./node_modules/scriptiges/knip.config.ts" "$@"
fi
