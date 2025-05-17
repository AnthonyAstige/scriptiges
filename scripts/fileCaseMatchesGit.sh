#!/usr/bin/env bash

# Check for file case mismatches between Git index and the filesystem
# Outputs git mv commands to fix mismatches.

exit_status=0

git ls-files | while read -r git_path; do
  # Get the directory and base name from the git path
  dir=$(dirname "$git_path")
  base=$(basename "$git_path")

  # Find the actual file path on the filesystem, respecting case, using case-insensitive search.
  # Use find with -maxdepth 1 to only search in the immediate directory.
  # Use -print and read to handle filenames. Assumes no newlines in filenames.
  # This approach is more robust than relying on xargs -0 for simple cases.
  actual_paths=$(find "$dir" -maxdepth 1 -iname "$base" -print)

  # Count the number of results
  num_actual_paths=$(echo "$actual_paths" | grep -c '^')

  # If no case-insensitive match is found, the file might not exist on the FS,
  # or find failed. We just skip this file as it's not a case mismatch issue.
  if [ "$num_actual_paths" -eq 0 ]; then
      continue
  elif [ "$num_actual_paths" -gt 1 ]; then
      # Multiple case-insensitive matches in the same directory is unexpected but possible
      # with unusual filenames or filesystems. Cannot automatically fix.
      echo "Warning: Found multiple case-insensitive matches for '$git_path' in directory '$dir':"
      echo "$actual_paths"
      exit_status=1
      continue
  fi

  # We found exactly one match. This is the actual case-sensitive path on the filesystem.
  actual_path="$actual_paths"

  # Normalize actual_path by removing leading ./ if it exists, for comparison purposes.
  # git ls-files paths are relative to the repo root without a leading ./.
  normalized_actual_path=$(echo "$actual_path" | sed 's/^\.\///')

  # Compare the Git path with the actual filesystem path (normalized for comparison).
  # If they differ, it's a case mismatch.
  if [ "$normalized_actual_path" != "$git_path" ]; then
    # Output the git mv command to correct the case.
    # Use the original git_path and the actual_path found by find.
    echo "git mv \"$git_path\" \"$actual_path\""
    # Set exit status to indicate a mismatch was found
    exit_status=1
  fi
done

exit $exit_status
