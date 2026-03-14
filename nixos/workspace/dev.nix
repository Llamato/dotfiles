{
  config,
  lib,
  pkgs,
  ...
}:
{

  programs.nix-ld.enable = lib.mkDefault true;

  /*programs.direnv = {
    enable = true;
    loadInNixShell = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };*/

  #Broken?
  /*documentation = {
    enable = true;
    dev.enable = true;
    man = {
      enable = true;
      mandoc.enable = true;
      generateCaches = true;
      man-db.enable = false;
    };
  };*/

  #Set up PGP
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  programs.seahorse.enable = true; # pgp gui

  #Set up git
  programs.git = {
    enable = true;
    lfs.enable = true;
    prompt.enable = true;
    lfs.enablePureSSHTransfer = true;
  };

  #Set up vscode
  /*programs.vscode.enable = true;
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    bbenoist.nix
    golang.go
    twxs.cmake
    zhwu95.riscv
    enkia.tokyo-night
    carrie999.cyberpunk-2020
  ];*/

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
    #linux-manual (Broken on M1)
    man-pages
    man-pages-posix
    bat
    cloc
    vscodium
    nixd
    nixfmt
    bun
    godot
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
