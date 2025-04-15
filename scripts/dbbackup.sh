#!/bin/sh

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

docker-compose run --rm backuppostgres once
