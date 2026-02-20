#!/bin/sh
mkdir -p /home/tina/umounts/bdata
sudo bcachefs unlock -k session /dev/sda1
sudo bcachefs mount /dev/sda1 /home/tina/umounts/bdata
