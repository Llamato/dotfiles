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
          owner = "AsahiLinux";
          repo = "linux";
          rev = "59b64a2cbf154b4315f300d1128a5aeb4616d010";
          hash = "sha256-tycMvapqRpeN0yY/Wr4nQ0V5GlIgvT9o2TTMF3itxuM=";
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
