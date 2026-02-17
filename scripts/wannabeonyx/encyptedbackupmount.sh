#!/bin/sh
mkdir -p /home/tina/umounts/bdata
sudo bcachefs unlock -k session /dev/sdd1
sudo bcachefs mount /dev/sdd1 /home/tina/umounts/bdata
