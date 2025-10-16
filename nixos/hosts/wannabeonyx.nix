# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Extra filesystems
  boot.supportedFilesystems = [ "bcachefs" "ntfs" "bitlocker" ];
  
  # Extra Kernel modules
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=2 video_nr=1,2 card_label="OBS Cam, Virt Cam" exclusive_caps=1
  '';

  #Clean temp dir on boot
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = true;

  #Enable Architecture emulation in QEMU
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux"];


  security.polkit.enable = true;

  networking.hostName = "wannabeonyx"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable network manager
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
  # You can disable this if you're only using the Wayland session.
  #services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  #Nautilus directory and network integrations.
  services.gvfs.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #Set up PGP
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  programs.seahorse.enable = true;

  # Enable Kwallet for GPG
  security.pam.services.kwallet.enable = true;

  # Enable Docker 
  #virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "tina" ]; #Bad because this is effectively equivalent to being root according to https://nixos.wiki/wiki/Docker (dla: 12.10.2025)
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  #Tina's own programs
  #gcalc = inputs.gcalc.packages.${pkgs.system}.default;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tina = {
    isNormalUser = true;
    description = "Tina";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" ];
    packages = with pkgs; [
      inputs.gcalc.packages.${pkgs.system}.default
      inputs.gcrypt.packages.${pkgs.system}.default
      git
      kdePackages.kate
      thunderbird
      vesktop
      ffmpeg
      sl
      cool-retro-term
      krita
      gimp3
      blender
      freecad
      audacity
      kdePackages.kdenlive
      vice
      vlc
      rawtherapee
      godot
      telegram-desktop
      fastfetch
      mesa
      mesa-demos
      vulkan-tools
      python3
      libreoffice-qt6-fresh
      simple-scan #gocr unpaper netpbm
      rnote
      wayland
      blueman
      obsidian
      virt-manager
      gparted
      zip
      rocmPackages.rocm-smi
      rsync
      xz
      stress
      ani-cli
      transmission_4-qt
      hardinfo2
      qdiskinfo
      tree
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Install steam
  #programs.steam.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Open Bordcast software
  programs.gphoto2.enable = true;
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi #optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    btop
    spacenavd
    libspnav
    dislocker
    liquidctl
    qemu
  ];

  systemd.user.services.spacenavd.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  #Video drivers
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.bluetooth.enable = true;

  #fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
    ];
  };

    #Enable linux lib dir.
    programs.nix-ld.enable = true;

  #Virtual machine manager setup
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["tina"];
  virtualisation.libvirtd = {
  enable = true;
  onBoot = "start";
  qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    swtpm.enable = true;
    ovmf = {
      enable = true;
      packages = [(pkgs.OVMF.override {
        secureBoot = true;
        tpmSupport = true;
        }).fd];
      };
    };
  };
}

