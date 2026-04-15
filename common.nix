{ config, ... }: {
  nix = {
    #package = pkgs.lixPackageSets.stable.lix;
    settings = {
      log-lines = "35";
      max-jobs = "auto";
      auto-optimise-store = true;
      nix-path = config.nix.nixPath;
      experimental-features = "nix-command flakes";
      #download-buffer-size = 524288000; # 512 MB
    };
    gc = {
      dates = "daily";
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
}
