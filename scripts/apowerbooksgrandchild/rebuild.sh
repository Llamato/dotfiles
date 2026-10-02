#!/bin/sh
sudo darwin-rebuild switch --flake .#apowerbooksgrandchild
#sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#apowerbooksgrandchild