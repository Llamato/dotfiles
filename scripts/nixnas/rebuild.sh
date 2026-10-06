#!/bin/sh
sudo nixos-rebuild --impure --no-reexec --flake .#nixnasduo --target-host 192.168.3.13 switch
sudo cp -if /run/current-system/init /sbin/init