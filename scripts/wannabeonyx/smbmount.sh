#!/bin/sh
sudo mount -t cifs //10.20.30.4/raid /home/tina/umounts/smb -o username=tina,vers=3.1.1,multichannel,uid=1000,gid=1000,file_mode=0644,dir_mode=0755
