#!/bin/bash

# CONFIG
BACKUP_HOME=/usr/local/backup/raspberry
USER=postgres
DROPBOX_UPLOADER=/usr/local/backup/Dropbox-Uploader/dropbox_uploader.sh
DROPBOX_UPLOADER_CONFIG=/root/.dropbox_uploader


# BACKUP CONFIG
# Postgres
POSTGRES_DATABASES=(redmine wakapi homelab myhomeinventory_dev myhomeinventory)
# Files
declare -A FILES=(["redmine_files"]="/usr/local/redmine/files" ["snipe-it_files"]="/usr/local/snipe-it/public/uploads")


# INITIALIZE PATHS
TODAY=$(date '+%Y-%m-%d')
BACKUP_FOLDER=$BACKUP_HOME"/"$TODAY
BACKUP_NAME=$TODAY"-raspi.tar.gz"

function backup_postgres_database() {

  local L_DATABASE=$1
  local L_BACKUP_PATH=$BACKUP_FOLDER"/"$TODAY"-"$L_DATABASE".sql"

  echo "Starting backup of $L_DATABASE database"
  echo "Saving backup to $L_BACKUP_PATH"

  sudo -H -u $USER bash -c "pg_dump -C $L_DATABASE > $L_BACKUP_PATH"
}


function create_backup_folder () {
  sudo -H -u $USER bash -c "mkdir -p $BACKUP_FOLDER"
}


function compress_folder () {
  cd $BACKUP_HOME

  echo "Compressing folders to $BACKUP_NAME"

  sudo -H -u $USER bash -c "tar -zcf $BACKUP_NAME $TODAY"
  if [ -z ${BACKUP_FOLDER+x} ]
  then
        echo "BACKUP_FOLDER not set. Is to risky to delete";
  else
        echo "Deleting $BACKUP_FOLDER"
        rm -r $BACKUP_FOLDER
  fi
}


function upload_to_dropbox() {
  echo "Uplaoding to dropbox"
  $DROPBOX_UPLOADER -f $DROPBOX_UPLOADER_CONFIG upload $BACKUP_HOME"/"$BACKUP_NAME "/"
}


function backup_postgres() {
  if [ ! -z ${POSTGRES_DATABASES+x} ];  then
      for POSTGRES_DB in ${POSTGRES_DATABASES[*]}; do
          backup_postgres_database $POSTGRES_DB
      done
  else
    echo "No postgres databases found to backup"

  fi
}

function backup_directory {

  local L_NAME=$1
  local L_DIRECTORY=$2
  local L_BACKUP_NAME=$L_NAME".tar.gz"
  local L_BACKUP_DIRECTORY=$BACKUP_FOLDER"/"$L_BACKUP_NAME
  echo "Saving $L_BACKUP_NAME from $L_DIRECTORY"

  tar -zcf $L_BACKUP_DIRECTORY $L_DIRECTORY
}


function backup_directories() {

  for filename in ${!FILES[*]}; do
    backup_directory $filename  ${FILES[$filename]}
  done
}


function remove_local_backup () {

   cd $BACKUP_HOME
  if [ -z ${BACKUP_NAME+x} ]
  then
        echo "BACKUP_NAME not set. Is to risky to delete";
  else
        echo "Deleting $BACKUP_NAME"
        rm -r $BACKUP_NAME
  fi

}

echo "Starting backup on $TODAY"
create_backup_folder
backup_directories
backup_postgres
compress_folder
upload_to_dropbox
remove_local_backup
echo "Ending backup on $TODAY"

exit 0