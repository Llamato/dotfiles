{ pkgs, inputs, ... }:
let
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
  hyprsplit = inputs.hyprsplit.packages.${pkgs.system}.hyprsplit;
  #easymotion = inputs.easymotion.packages.${pkgs.system}.hyprland-easymotion;
  xdg-desktop-portal-hyprland = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  split-monitor-workspaces =
    inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces;
  #hyprtrails = inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails; # As of yet unused
in
{
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  programs.hyprland = {
    enable = true;
    package = hyprland;
    xwayland.enable = true;
    portalPackage = xdg-desktop-portal-hyprland;
    #plugins = [split-monitor-workspaces hyprsplit easymotion];
    #plugins = [ hyprsplit easymotion ];
    plugins = [
      split-monitor-workspaces
      hyprsplit
    ]; # easymotion
  };

  #Nautilus File Manager config
  services.gvfs.enable = true;
  programs.dconf.enable = true;
  services.gnome.sushi.enable = true;
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "cool-retro-term";
  };

  #Webbrowser
  programs.firefox.enable = true;

  #xdg config
  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "cool-retro-term.desktop"
      ];
    };
  };

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
    ffmpegthumbnailer
    waybar
    dunst
    (pkgs.callPackage inputs.nixpkgs-unstable { }).vicinae
    kitty cool-retro-term
    nautilus
    gnome-disk-utility
    imv
    gtk-engine-murrine
    gnome-themes-extra
    nwg-look
    killall
    xorg.xrandr
    libnotify
    playerctl
    kdePackages.breeze
    kdePackages.breeze-icons
    qt6Packages.qt6ct
    hyprpaper
    hypridle
    hyprlock
    hyprpicker
    hyprpolkitagent
    adwaita-icon-theme
    phinger-cursors
    tokyonight-gtk-theme
    networkmanagerapplet
    file-roller
    gnome-keyring
    pwvucontrol
  ];
}
