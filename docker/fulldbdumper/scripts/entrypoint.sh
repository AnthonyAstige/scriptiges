#!/bin/sh

perform_backup() {
  TIMESTAMP=$(date +'%Y-%m-%d.%H:%M:%S')
  BACKUP_PATH="/backups/"
  BACKUP_FILE="${POSTGRES_DB}-${TIMESTAMP}.sql"

  echo "Starting backup at ${TIMESTAMP}..."
  PGPASSWORD=${PGPASSWORD} pg_dump -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -U ${POSTGRES_USER} ${POSTGRES_DB} >"${BACKUP_PATH}${BACKUP_FILE}"
  NEW_BACKUP_FILE="${BACKUP_PATH}${BACKUP_FILE}.gz"
  gzip "${BACKUP_PATH}${BACKUP_FILE}"

  if [ $? -eq 0 ]; then
    LATEST_BACKUP=$(ls -t ${BACKUP_PATH}*.gz | head -n 2 | tail -n 1)
    NEW_CHECKSUM=$(md5sum "${NEW_BACKUP_FILE}" | awk '{ print $1 }')
    if [ -f "$LATEST_BACKUP" ]; then
      LATEST_CHECKSUM=$(md5sum "$LATEST_BACKUP" | awk '{ print $1 }')
      if [ "$NEW_CHECKSUM" == "$LATEST_CHECKSUM" ]; then
        echo "Backup is identical to the previous one. Deleting ${NEW_BACKUP_FILE}..."
        rm "${NEW_BACKUP_FILE}"
      else
        echo "Backup successful: ${BACKUP_FILE}.gz"
      fi
    else
      echo "Backup successful: ${BACKUP_FILE}.gz"
    fi
  else
    echo "Backup failed"
    exit 1
  fi
}

if [ "$1" = "" ]; then
  # Scheduled backups
  echo "Starting scheduled backups every ${POSTGRES_BACKUP_INTERVAL} seconds as service ..."
  while true; do
    perform_backup
    sleep ${POSTGRES_BACKUP_INTERVAL}
  done
else
  # Manual backup on container start
  perform_backup
fi
