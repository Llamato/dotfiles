#!/bin/sh
# bpim1 is cross-compiled (nixpkgs.buildPlatform = x86_64-linux, hostPlatform = armv7l-linux).
#
# --no-reexec is required for cross rebuilds: by default nixos-rebuild first builds
# .#nixosConfigurations.bpim1.config.system.build.nixos-rebuild (an *armv7l* binary,
# meant for the target board), re-execs it here, and that emulated armv7 nix reports
# "Current system: armv7l-linux" and then refuses the x86_64-built parts of the cross
# system with "platform mismatch" (system-path.drv, toplevel, ...).
# It is also another source of qemu work on the build machine.
sudo nixos-rebuild -L --impure --flake .#bpim1 --target-host 192.168.3.17 --no-reexec switch
