{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  linux-fairydust = pkgs.callPackage (
    {
      stdenv,
      lib,
      fetchFromGitHub,
      buildLinux,
      linuxPackagesFor,
      _kernelPatches ? [],
    }: let
      kernel = buildLinux {
        inherit stdenv lib;
        pname = "linux-asahi-fairydust";
        version = "7.1.13";
        modDirVersion = "7.1.13";
        extraMeta.branch = "7.1";

        src = fetchFromGitHub {
          owner = "llamato";
          repo = "linux-asahi";
          rev = "3c2312b420cd57d0f1d9947cfc014a951d2f5523";
          hash = "sha256-W3yMSUe6xa+M/X0k86kbCS4g3d7jJmO3WV9L/5rQRhI=";
        };

        kernelPatches =
          [
            {
              name = "Asahi config";
              patch = null;
              structuredExtraConfig = with lib.kernel; {
                ARM64_16K_PAGES = yes;
                ARM64_MEMORY_MODEL_CONTROL = yes;
                ARM64_ACTLR_STATE = yes;
                APPLE_WATCHDOG = yes;
                APPLE_M1_CPU_PMU = yes;
                HID_APPLE = module;
                APPLE_PMGR_MISC = yes;
                APPLE_PMGR_PWRSTATE = yes;
              };
              features.rust = true;
            }
            # Adds DRM_IOCTL_ASAHI_GET_STATS to the asahi GPU driver, which btop uses for AGX
            # utilisation and clock statistics (see btop docs/asahi_agx.md).
            # Note: keep this out of boot.kernelPatches, nixpkgs appends those to the kernel
            # derivation as well, which would apply the patch twice.
            {
              name = "asahi-get-stats";
              patch = ../patches/asahi-get-stats.patch;
            }
          ]
          ++ _kernelPatches;
      };
    in
      lib.recurseIntoAttrs (linuxPackagesFor kernel)
  ) {_kernelPatches = config.boot.kernelPatches;};
in {
  boot = {
    kernelPackages = lib.mkForce linux-fairydust;
    extraModulePackages = [
      config.boot.kernelPackages.evdi # DisplayLink USB display adapter support
    ];
  };

  # btop built from the btop flake input (~/git/btop) with the Asahi AGX GPU collector, installed as
  # bin/btop-asahi so the plain btop from monitoring.nix stays available.
  environment.systemPackages = [
    inputs.btop.packages.${pkgs.system}.btop-asahi
  ];
}
