{ config, pkgs, ... }: {
  nix = {
    #package = pkgs.lixPackageSets.stable.lix;
    optimise.automatic = true;
    settings = {
      substituters = [
        "http://10.20.30.3:5000/"
        "http://192.168.3.14:5000/"
        "https://homelab.lllamato.dev:5000"
      ];
      trusted-public-keys = [ 
        "wannabeinthebasement:Gwgwnvx67OKz2htvy/p770qeajfVUrVAlI+K3nxcOJM="
        "192.168.3.14-1:WN5/PjgQlzQ+PSDMXjv+B5rXKzkFtRg1+/UkAmnEvkM="
        "homelab.llamato.dev:6znaEdEvZ1P5GQXD1BZ5KUY0uP56/t2iu/dMj0fJJg8="
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
