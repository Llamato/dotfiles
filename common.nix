{ config, pkgs, ... }: {
  nix = {
    #package = pkgs.lixPackageSets.stable.lix;
    optimise.automatic = true;
    settings = {
      extra-trusted-substituters = [
        "http://10.20.30.3:3000/"
        "http://192.168.3.14:3000/"
        "https://homelab.lllamato.dev:3000"
      ];
      extra-trusted-public-keys = [ 
        "wannabeinthebasement:Gwgwnvx67OKz2htvy/p770qeajfVUrVAlI+K3nxcOJM="
        "homelab.llamato.dev:6znaEdEvZ1P5GQXD1BZ5KUY0uP56/t2iu/dMj0fJJg8="
      ];
      trusted-users = [ "tina" ];
      log-lines = "35";
      max-jobs = "auto";
      nix-path = config.nix.nixPath;
      experimental-features = "nix-command flakes";
      allow-import-from-derivation = true;
      #download-buffer-size = 524288000; # 512 MB
    };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    prompt.enable = true;
    lfs.enablePureSSHTransfer = true;
  };
}
