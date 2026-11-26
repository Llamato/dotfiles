{
  inputs,
  config,
  pkgs,
  ...
}:
let
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  nix = {
    #package = pkgs.lixPackageSets.stable.lix;
    optimise.automatic = true;
    settings = {
      extra-substituters = [
        #"http://homelab.llamato.dev:5000"
      ];
      extra-trusted-public-keys = [
        "192.168.3.14-1:WN5/PjgQlzQ+PSDMXjv+B5rXKzkFtRg1+/UkAmnEvkM="
      ];
      trusted-users = [
        "root"
        "tina"
      ];
      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
        "gccarch-znver5"
        "gccarch-armv7-a"
        "uid-range"
      ];
      log-lines = "35";
      max-jobs = "auto";
      nix-path = config.nix.nixPath;
      experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
        "cgroups"
      ];
      allow-import-from-derivation = true;
      connect-timeout = 1;
      auto-allocate-uids = true;
    };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
  };
  programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
  environment.systemPackages = with pkgs; [
    git
    sops
  ];
}
