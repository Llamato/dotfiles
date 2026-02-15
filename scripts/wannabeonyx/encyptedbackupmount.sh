#!/bin/sh
sudo bcachefs unlock -k session /dev/sdc1
sudo bcachefs mount /dev/sdc1 /home/tina/umounts/bdata
