{ pkgs, ... }: {

  #Nix
  #nix.config.trusted-users = [ "root" "tina" ];
  nixpkgs.config.allowUnfree = true;
  nix.distributedBuilds = true;
  nix.buildMachines = [ {
	 hostName = "builder";
	 system = "aarch64-linux";
   protocol = "ssh-ng";
	 systems = [ "aarch64-linux" ];
	 maxJobs = 1;
	 speedFactor = 2;
	 supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
	 mandatoryFeatures = [ ];
  }];

  networking = {
    hostName = "actuallythinkpad";
    networkmanager.enable = true;
  };
  
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  #Cosmic Desktop
  services.desktopManager.cosmic.enable = true;
  
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    wget
    screen
    fastfetch
    btop htop
    vesktop
    gparted
    telegram-desktop
    localsend
    sl
    qemu
    flashprog tlp
    toolbox
  ];

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  system.stateVersion = "25.11"; # Did you read the comment?


  #Tinas edits

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  #networking.wireless.iwd = {
  #  enable = true;
  #  settings.General.EnableNetworkConfiguration = true;
  #};

users.users = {
  tina = {
      isNormalUser = true;
      description = "Tina";
      extraGroups = [
        "networkmanager"
        "wheel"
        "scanner"
        "lp"
        "podman"
      ];
      
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmuHyyOtAxG1GSuqIoeeGfV8XfLQGzS6zalYuAumlD+ tina_modern"
        #"ssh-falcon1024 AAAADnNzaC1mYWxjb24xMDI0AAAHAQqaziOEHQMfjzzldpYUP3+mYzpujWGR8IvWrIJtdHyjFHdt61Q9UGj3QAdLcjQGXk1xcW0l6+2kHi1IZXh/y35BTixUj+sdsehlqGOnhWFkPepJonQkRm>
        #"ssh-falcon512 AAAADXNzaC1mYWxjb241MTIAAAOBCYselVfYAiMNMr/352O5W05OFNCDgR/VQOKtihMduSTDbZFYUxXU+b8Kh3IBg9A3aw0FcMp6PayAiu5oV5WL0zdoivJP1pGakIKUdFhdFCH9xtfIiJGQP9b>
      ];
    };
#  romana = {
#      isNormalUser = true;
#      password = "6301";
#      openssh.authorizedKeys.keys = [
#        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM30of3vRzm2aB5f+b9HVVNKh811emm7ZD4OW9v2tfcx u0_a468@localhost"
#        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAING7VPuszU2P1fYm/h8ZTywzfNhHHPZFFbL2pUdIQfSq flash@bios"
#      ];
#    };
  };
}
