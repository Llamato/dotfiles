{ pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      ids.gids.nixbld = 350;
      environment.systemPackages = with pkgs; [
          fastfetch
          hyfetch
          gnupg
          git
        ];

      # Auto upgrade nix package
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      #programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      # Sudo with touch ID
      security.pam.services.sudo_local.touchIdAuth = true;
}
