{ config, pkgs, ... }: {
  nix = {
    #package = pkgs.lixPackageSets.stable.lix;
    optimise.automatic = true;
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "http://192.168.3.14:5000/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
