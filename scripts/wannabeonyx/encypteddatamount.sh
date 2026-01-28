#!/bin/sh
sudo bcachefs unlock -k session /dev/sdi1
sudo bcachefs mount /dev/sdi1 /home/tina/umounts/data
