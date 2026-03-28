#!/bin/sh
mkdir -p /home/tina/umounts/ltobuffer
sudo bcachefs unlock -k session /dev/disk/by-uuid/1d8ec0f2-a7a1-4369-a6bc-eaf5fd228034
sudo bcachefs mount /dev/disk/by-uuid/1d8ec0f2-a7a1-4369-a6bc-eaf5fd228034 /home/tina/umounts/ltobuffer
