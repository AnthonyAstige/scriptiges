#!/bin/sh

# Function to find the project root (directory containing .git)
find_project_root() {
  local current_dir="$1"
  while [ ! -d "$current_dir/.git" ]; do
    if [ "$current_dir" = "/" ]; then
      echo "Error: Not inside a git repository."
      exit 1
    fi
    current_dir=$(dirname "$current_dir")
  done
  echo "$current_dir"
}

# Find the project root directory, starting from the current working directory
PROJECT_ROOT=$(find_project_root "$(pwd)")
echo "PROOT: $PROJECT_ROOT"

# Define the backup directory relative to the project root
BACKUP_DIR="${PROJECT_ROOT}/.data/postgres_dumps"
echo "BACKUP_DIR: $BACKUP_DIR"

# Check if the backup directory exists, and create it if it doesn't
if [ ! -d "${BACKUP_DIR}" ]; then
  mkdir -p "${BACKUP_DIR}"
  if [ $? -ne 0 ]; then
    echo "Error: Unable to create backup directory ${BACKUP_DIR}"
    exit 1
  fi
fi

# Check if environment variables are set
if [ -z "${DOCKER_CONTAINER_FULLDBDUMPER_NAME}" ]; then
  echo "Error: DOCKER_CONTAINER_FULLDBDUMPER_NAME is not set"
  exit 1
fi
if [ -z "${APPLICATION_TZ}" ]; then
  echo "Error: APPLICATION_TZ is not set"
  exit 1
fi
if [ -z "${POSTGRES_PORT}" ]; then
  echo "Error: POSTGRES_PORT is not set"
  exit 1
fi
if [ -z "${POSTGRES_USER}" ]; then
  echo "Error: POSTGRES_USER is not set"
  exit 1
fi
if [ -z "${POSTGRES_DB}" ]; then
  echo "Error: POSTGRES_DB is not set"
  exit 1
fi
if [ -z "${POSTGRES_BACKUP_INTERVAL}" ]; then
  echo "Error: POSTGRES_BACKUP_INTERVAL is not set"
  exit 1
fi
if [ -z "${POSTGRES_PASSWORD}" ]; then
  echo "Error: POSTGRES_PASSWORD is not set"
  exit 1
fi

# docker-compose -f "${SCRIPT_DIR}/../docker-compose.yml" run --rm backuppostgres once
