#!/bin/sh
mkdir -p /home/tina/umounts/bdata
sudo bcachefs unlock -k session /dev/sdl1
sudo bcachefs mount /dev/sdl1 /home/tina/umounts/bdata
