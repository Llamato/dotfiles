#!/bin/sh
sudo nixos-rebuild switch --flake .#nixnas --show-trace
sudo cp -if /run/current-system/init /sbin/init