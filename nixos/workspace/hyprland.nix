{pkgs, inputs, ...}: let
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
in {
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  programs.hyprland = {
    enable = true;
    package = hyprland;
    xwayland.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
    noto-fonts-cjk-serif
    nerd-fonts.jetbrains-mono
  ];

  # Secrets and keys management
  programs.seahorse.enable = true; # cringe
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.ly.enableGnomeKeyring = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # needed for nautilus stuff
  services.gvfs.enable = true;
  programs.dconf.enable = true;
  services.gnome.sushi.enable = true;

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "kitty.desktop"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    waybar dunst kitty nautilus
    wl-clipboard inputs.nixpkgs-unstable.vicinae
    gtk-engine-murrine gnome-themes-extra
    grim slurp ffmpegthumbnailer #devnotify 
    killall xorg.xrandr libnotify playerctl pwvucontrol
    hyprpaper hypridle hyprlock hyprpicker hyprpolkitagent
    adwaita-icon-theme phinger-cursors tokyonight-gtk-theme
    kdePackages.breeze kdePackages.breeze-icons kdePackages.qt6ct 
    #fcitx5 fcitx5-gtk fcitx5-mozc 
  ];
}