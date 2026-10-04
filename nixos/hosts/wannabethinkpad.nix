{
  config,
  pkgs,
  lib,
  ...
}:
let
  semisecrets = (import ../../semisecrets.nix { inherit config pkgs lib; });
in
{

  system.stateVersion = "26.05";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [
    "xfs"
    "ntfs"
    "bitlocker"
    "exfat"
    "vfat"
    "f2fs"
  ];

  boot.binfmt.emulatedSystems = [
    "x86_64-linux"
    "i686-linux"
  ];

  #Nix
  #nix.config.trusted-users = [ "root" "tina" ];
  nixpkgs.config.allowUnfree = true;
  nix.distributedBuilds = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  networking = {
    hostName = "wannabethinkpad";
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

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    wget
    screen
    vesktop
    gparted
    localsend
    qemu
    powertop
    ncdu
    kdePackages.krfb
    muvm
    file
  ];

  #Vr Things
  programs.alvr.enable = true;

  #VNC for wayland
  programs.wayvnc.enable = true;

  #Enable firefox bowser
  programs.firefox.enable = true;

  #Enable stream
  #programs.steam.enable = true;

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

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.desktopManager.cosmic.enable = true;

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
      openssh.authorizedKeys.keys = semisecrets.semisecrets.tina.keys.ssh;
    };
  };
}
