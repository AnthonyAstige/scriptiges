#!/bin/sh

# Bandaid for error:
# > (node:17827) ExperimentalWarning: Importing JSON modules is an experimental feature and might change at any time
# - https://github.com/nodejs/node/issues/51347#issuecomment-1893074523
# Hopefully we don't need this when node updates as JSON modules seem standard?
# - https://github.com/nodejs/node/issues/51347#issuecomment-2476696604
# - Anthony 2025-04-04
export NODE_OPTIONS="--disable-warning=ExperimentalWarning"
npx eslint "$@"
