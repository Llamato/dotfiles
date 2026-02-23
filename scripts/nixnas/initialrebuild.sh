#!/bin/sh
if [ $(whoami) -eq "root" ]; then
    nixos-rebuild switch --flake .#nixnas --show-trace
    cp -if /run/current-system/init /sbin/init
else
    echo "Rebuilt can not be completed with user level privlages, please run as root."
fi