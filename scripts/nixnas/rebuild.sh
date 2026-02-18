#!/bin/sh
sudo nixos-rebuild switch --flake .#nixnas --show-trace
cp -f /run/current-system/init /sbin/init