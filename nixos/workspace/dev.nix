{config, lib, pkgs, ...}: {
  
  programs.nix-ld.enable =  lib.mkDefault true;

  programs.direnv = {
    enable = true;
    loadInNixShell = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  documentation = {
    enable = true;
    dev.enable = true;
    man = {
      enable = true;
      mandoc.enable = true;
      generateCaches = true;
      man-db.enable = false;
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    prompt.enable = true;
    lfs.enablePureSSHTransfer = true;
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
    linux-manual 
    man-pages 
    man-pages-posix
    bat
    cloc
    vscodium
    #jetbrains.idea-ultimate jetbrains.jdk
    #jetbrains.rider
    #jetbrains.webstorm nodejs_24
    #jetbrains.clion
    lmstudio
    nixd
    bun
    godot
    mesa clinfo mesa-demos vulkan-tools
    vice
    jdk8
    renderdoc
    kmod
  ];

  # clangd service
  systemd.user.services.clangd.enable = true;

  # Adb setup
  programs.adb.enable = true;
  users.users.tina.extraGroups = [ "adbusers" ];
  nixpkgs.config.android_sdk.accept_license = true;

  # Waka Time for Kate
  #services.kate-wakatime.enable = true;
}
