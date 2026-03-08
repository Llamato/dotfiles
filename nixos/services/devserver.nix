{
  config,
  lib,
  pkgs,
  ...
}:
{

  programs.nix-ld.enable = lib.mkDefault true;
  #Set up git
  programs.git = {
    enable = true;
    lfs.enable = true;
    prompt.enable = true;
    lfs.enablePureSSHTransfer = true;
  };

  environment.systemPackages = with pkgs; [
    imhex
    lldb
    bat
    bat-extras.batman
    gh
    lazygit
    config.boot.kernelPackages.perf
    #linux-manual (Broken on M1)
    man-pages
    man-pages-posix
    cloc
    nixd
    nixfmt
    clinfo
    jdk8
    kmod
    python3
    nmap
    meld
    file
    ubootTools
    toybox
  ];

  # clangd service
  systemd.user.services.clangd.enable = true;

  # Adb setup
  #programs.adb.enable = true;
  #users.users.tina.extraGroups = [ "adbusers" ];
  #snixpkgs.config.android_sdk.accept_license = true;

  # Waka Time for Kate
  #services.kate-wakatime.enable = true;
}
