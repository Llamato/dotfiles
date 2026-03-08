#!/bin/sh
sudo nixos-rebuild --impure --flake .#bpim1 --target-host 192.168.3.17 switch