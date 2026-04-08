#!/bin/sh
sudo nix-collect-garbage
sudo nix-collect-garbage -d
nix-collect-garbage
nix-collect-garbage -d