#!/bin/sh
mkdir -p /home/tina/umounts/bdata
sudo bcachefs unlock -k session /dev/disk/by-uuid/1bc5c371-9d22-4c59-a835-b6e79862a935
sudo bcachefs mount /dev/disk/by-uuid/1bc5c371-9d22-4c59-a835-b6e79862a935 /home/tina/umounts/bdata
