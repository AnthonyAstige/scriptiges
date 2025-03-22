#!/bin/sh

set -e # Exit on error

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "$0")

# TODO: Get all of these scripts in and workng in this general script repo
# TODO: * Once all pulled in replace main app to use this instead
"$SCRIPT_DIR/databaseDumpstructure.js"
npx prisma db pull --force
npx prisma generate
# npm run db:validate-prisma-schema
# npm run splitSchema
# npm run db:dumpfull
