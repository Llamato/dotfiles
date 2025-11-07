{config, lib, pkgs, ...}: {
  programs.nix-ld.enable = true;

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
    jetbrains.idea-ultimate jetbrains.jdk
    jetbrains.rider
    jetbrains.webstorm nodejs_24
    jetbrains.clion
    kicad
    lmstudio
    nil
  ];

  #clangd service
  systemd.user.services.clangd.enable = true;
}