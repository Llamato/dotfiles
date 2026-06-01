{ config, ... }: {
  nix = {
    #package = pkgs.lixPackageSets.stable.lix;
    optimise.automatic = true;
    settings = {
      log-lines = "35";
      max-jobs = "auto";
      nix-path = config.nix.nixPath;
      experimental-features = "nix-command flakes";
      #download-buffer-size = 524288000; # 512 MB
    };
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;
}
