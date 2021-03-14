# RaspberryDropboxBackup

This a quick script to backup your directories and postgres databases into dropbox.

This script will backup with the postgres account each database defined in the array at the begining of the script and it will also pack the files defined in the associated array for files.


## Config

You will have to configure your paths at the beginin after installing [DropboxUploader](https://github.com/andreafabrizi/Dropbox-Uploader/) to the the communication with dropbox.
The configure your databases and file paths.

This may give a hint on how I configured my project:
```bash
git clone https://github.com/andreafabrizi/Dropbox-Uploader.git
cd Dropbox-Uploader/
chmod +x dropbox_uploader.sh
./dropbox_uploader.sh
mkdir -p /usr/local/backup/raspberry
cd /usr/local/backup
chmod 700 backup_raspi.sh
usermod -a -G backup postgres
chgrp -R backup /usr/local/backup/raspberry/
chmod -R g+w /usr/local/backup/raspberry/
chown postgres raspberry/
```


## Usage

Once you have the paths configured just execute it or create a cronjob. 

Example for a backup every monday:
```bash
# Add this to crontab -e
echo 0 5 * * mon /usr/local/backup/backup_raspi.sh >>/usr/local/backup/backup.log 2>&1
```

## Limitations

This script has been done quickly without taking care for exceptions. Just to have a backup in the databases of some local projects. This will work for you if you want something quick that works out of the box by just putting your paths. 

If you have different permissions/users in postgres you may have to do some work.
