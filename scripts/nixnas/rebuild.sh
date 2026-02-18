#!/bin/sh
sudo nixos-rebuild switch --flake .#nixnas --show-trace
cp /run/current-system/init /sbin/init