#!/bin/bash

BACKUP_DIR="/var/db/postgres0/backups"
WAL_ARCHIVE_DIR="/var/db/postgres0/wal_archive"
REMOTE_SERVER="postgres0@pg110:/var/db/postgres0/backups"

mkdir -p $BACKUP_DIR
mkdir -p $WAL_ARCHIVE_DIR

BACKUP_DIR_NAME="backup_$(date +%F)"

echo "Создаю полную резервную копию..."
pg_basebackup -D "$BACKUP_DIR/$BACKUP_DIR_NAME" -Ft -z -P -X stream -U postgres0 -h 192.168.11.103 -p 9581

echo "Копирую резервную копию на резервный сервер..."
scp -r "$BACKUP_DIR/$BACKUP_DIR_NAME" $REMOTE_SERVER

# Удаление старых резервных копий на основной системе (срок хранения - 7 дней)
echo "Удаляю старые резервные копии на основной системе..."
find $BACKUP_DIR -type d -mtime +7 -exec rm -rf {} \;

# Удаление старых резервных копий на резервной системе (срок хранения - 28 дней)
echo "Удаляю старые резервные копии на резервной системе..."
ssh postgres0@pg110 "find /var/db/postgres0/backups -type d -mtime +28 -exec rm -rf {} \;"

# Архивирование и копирование WAL на резервную систему
echo "Архивирую и копирую WAL на резервный сервер..."
cp /var/db/postgres0/pg_wal/* $WAL_ARCHIVE_DIR/

# Копирование WAL архивов на резервный сервер
scp -r $WAL_ARCHIVE_DIR/* $REMOTE_SERVER/wal_archive/

# Удаление старых WAL архивов на основной системе (срок хранения - 7 дней)
echo "Удаляю старые WAL архивы на основной системе..."
find $WAL_ARCHIVE_DIR -type f -mtime +7 -exec rm -f {} \;

# Удаление старых WAL архивов на резервной системе (срок хранения - 28 дней)
echo "Удаляю старые WAL архивы на резервной системе..."
ssh postgres0@pg110 "find /var/db/postgres0/wal_archive -type f -mtime +28 -exec rm -f {} \;"

echo "Резервное копирование завершено!"
