{ config, lib, pkgs, ... }:
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [
    "bcachefs"
    "xfs"
    "ntfs"
    "bitlocker"
    "exfat"
    "vfat"
    "apfs"
  ];  
  boot.binfmt.emulatedSystems = [
  "x86_64-linux"
  "armv7l-linux"
  "riscv64-linux"
  ];

  #Nix remote building
  nix.config.trusted-users = [ "root" "tina" ];
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

  networking.hostName = "wannabethinkpad"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
    #services.xserver.xkb = {
    #layout = "de";
    #variant = "";
  #};
  #services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  #Cosmic Desktop
  services.desktopManager.cosmic.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
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
   ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?


  #Tinas edits
  hardware.asahi.peripheralFirmwareDirectory = /etc/nixos/firmware;
  
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
        "docker"
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
