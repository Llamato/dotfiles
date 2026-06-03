{ config, ... }: {
  nix = {
    #package = pkgs.lixPackageSets.stable.lix;
    optimise.automatic = true;
    settings = {
      useSubstitutes = true;
      trusted-substituters = [ "http://192.168.3.14:3000" ];
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
}
