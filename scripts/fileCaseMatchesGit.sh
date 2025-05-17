#!/usr/bin/env bash

# Check for file case mismatches between Git index and the filesystem
git ls-files | while read -r file; do
  # Check if the file exists on the filesystem
  [ ! -e "$file" ] && echo "Missing: $file" && continue

  # Find the actual file path on the filesystem, respecting case
  # Use find with -maxdepth 1 to only search in the immediate directory
  # Use -print0 and xargs -0 to handle filenames with spaces or special characters
  actual=$(find "$(dirname "$file")" -maxdepth 1 -name "$(basename "$file")" -print0 | xargs -0)

  # Compare the Git path with the actual filesystem path
  if [ "$actual" != "$file" ]; then
    echo "Case mismatch: Git: $file  → FS: $actual"
  fi
done
