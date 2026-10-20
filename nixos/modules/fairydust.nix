{
  lib,
  pkgs,
  config,
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
          owner = "AsahiLinux";
          repo = "linux";
          rev = "ce9f2eba72c061a50b2d790450e90af3439d8c24";
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
}
