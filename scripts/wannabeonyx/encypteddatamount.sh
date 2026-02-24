#!/bin/sh
mkdir -p /home/tina/umounts/data
sudo bcachefs unlock -k session /dev/disk/by-uuid/9bae3504-266e-46ba-8dc7-d33858eae1c5
sudo bcachefs mount /dev/disk/by-uuid/9bae3504-266e-46ba-8dc7-d33858eae1c5 /home/tina/umounts/data
