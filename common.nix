{ config, pkgs, ... }: let 
  isInHomelab = true;
in {
  nix = {
    #package = pkgs.lixPackageSets.stable.lix;
    optimise.automatic = true;
    settings = {
      extra-substituters = if isInHomelab 
      then [
        #"http://10.20.30.3:5000"
      ]
      else [
        "http://homelab.llamato.dev:5000"
      ];
      extra-trusted-public-keys = [
        "192.168.3.14-1:WN5/PjgQlzQ+PSDMXjv+B5rXKzkFtRg1+/UkAmnEvkM="
      ];
      trusted-users = [ "root" "tina" ];
      system-features = [ 
        "gccarch-armv7-a"
      ];
      log-lines = "35";
      max-jobs = "auto";
      nix-path = config.nix.nixPath;
      experimental-features = "nix-command flakes";
      allow-import-from-derivation = true;
      connect-timeout = 1;

    };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };
  environment.systemPackages = with pkgs; [ 
    git
  ];
}
