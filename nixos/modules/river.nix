{ pkgs, ... }: {
  users.users.tina = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    initialPassword = "llamato";
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "cool-retro-term.desktop"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    river-classic
    river-bsp-layout
    kitty
    bun
    fastfetch
    tofi
    alacritty
    bash
    wezterm
    foot
    cool-retro-term
    discord
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    xdg-desktop-portal
    slurp
  ];

  programs.firefox.enable = true;
}
