{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs = {
    nix-ld = {
      enable = lib.mkDefault true;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
    seahorse = {
      enable = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      prompt.enable = true;
      lfs.enablePureSSHTransfer = true;
    };
    direnv = {
      enable = true;
      loadInNixShell = true;
    };
  };

  environment.systemPackages = with pkgs; [
    renderdoc
    imhex
    lldb
    tracy
    bat
    bat-extras.batman
    gh
    lazygit
    github-desktop
    config.boot.kernelPackages.perf
    man-pages
    man-pages-posix
    bat
    cloc
    vscodium
    nixd
    nixfmt
    bun
    #godot
    clinfo
    vice
    jdk8
    renderdoc
    kmod
    python3
    nmap
    ghidra
    meld
    file
    vscode-fhs
    uutils-coreutils-noprefix
    distrobox 
  ];

  # clangd service
  systemd.user.services.clangd.enable = true;

  # distrobox
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
}
