#!/bin/sh
mkdir -p ~/umounts/llamkatttsmb
sudo mount -t cifs //192.168.3.11/raid ~/umounts/llamkatttsmb -o username=tina,vers=3.1.1,multichannel,uid=1000,gid=1000,file_mode=0644,dir_mode=0755
