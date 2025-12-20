# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }: {

  # Lix (What the hell is lix?)
  #nix.package = pkgs.lixPackageSets.stable.lix;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Extra filesystems
  boot.supportedFilesystems = [ "bcachefs" "xfs" "ntfs" "bitlocker" "exfat" "vfat" ];
  
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
  boot.tmp.useTmpfs = false;

  #Enable Architecture emulation in QEMU
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" "riscv64-linux" ];

  security.polkit.enable = true;

  networking.hostName = "wannabeonyx"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable network manager
  #networking.networkmanager.enable = true;

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

  # Enable sound without pipewire.
  services.pulseaudio = {
    enable = false;
    
    # Daemon configuration to fix auto-regulation
    extraConfig = ''
      # Disable echo cancellation/AGC
      unload-module module-echo-cancel
      load-module module-echo-cancel aec_method=webrtc aec_args="analog_gain_control=0,digital_gain_control=0"
    '';
  };

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    extraConfig.pipewire = {
    "99-mic-fix" = {
      "context.modules" = [
        {
          name = "libpipewire-module-access";
          args = {
            rules = [
              {
                matches = [
                  [
                    { "application.process.binary" = "electron"; }
                    { "application.process.binary" = "webcord";  }
                    { "application.process.binary" = "firefox";  }
                    { "application.process.binary" = "vesktop";  }
                  ]
                ];
                default_permissions = "rx";
              }
            ];
          };
        }
      ];
    };
  };
};

  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #Set up PGP
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  programs.seahorse.enable = true; #pgp gui

  # Enable Kwallet for GPG
  security.pam.services.kwallet.enable = true;

  # Enable Docker 
  #virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "tina" ]; #Bad because this is effectively equivalent to being root according to https://nixos.wiki/wiki/Docker (dla: 12.10.2025)
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    tina = {
      isNormalUser = true;
      description = "Tina";
      extraGroups = [ "networkmanager" "wheel" "scanner" "lp" ];
      packages = with pkgs; [
        
      ];
    };

    romana = {
    isNormalUser = true;
    home = "/home/romana";
    password = "6301";
    openssh.authorizedKeys.keys = [ 
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM30of3vRzm2aB5f+b9HVVNKh811emm7ZD4OW9v2tfcx u0_a468@localhost" 
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAING7VPuszU2P1fYm/h8ZTywzfNhHHPZFFbL2pUdIQfSq flash@bios"
      ];
    };
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
    wget dig
    spacenavd
    libspnav
    dislocker
    qemu
    pwvucontrol
    powertop
    ryzen-monitor-ng
    sg3_utils iotop mission-center
    inetutils iperf3 vnstat
    cifs-utils
    (btop.override { rocmSupport = true; })

    #Formerly user packages
    inputs.gcalc.packages.${pkgs.system}.default
    inputs.gcrypt.packages.${pkgs.system}.default
    inputs.gbounce.packages.${pkgs.system}.default
    inputs.stenc.packages.${pkgs.system}.stenc archivemount
    git
    kdePackages.kate
    thunderbird
    vesktop discord
    ffmpeg
    sl
    cool-retro-term
    kdePackages.kdenlive rawtherapee
    vlc
    gimp3
    telegram-desktop
    fastfetch cpufetch gpufetch
    python3
    libreoffice-qt6-fresh
    simple-scan gocr unpaper netpbm
    rnote
    wayland
    blueman
    obsidian
    virt-manager
    gparted
    zip xz rsync
    stress
    hardinfo2
    qdiskinfo
    tree
    nix-tree
    element-desktop cinny-desktop
    texlive.combined.scheme-full
    p7zip
    hexedit
    openssl
    kdePackages.ark
    jdk8 jdk24
    wlvncc
    distrobox
    monero-gui
    kdePackages.kget
    oqs-provider #quantum security
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "mbedtls-2.28.10"
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
  services.openssh = {
    enable = true;
    ports = [ 3001 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
      AllowUsers = [
        "tina"
        "romana"
      ];
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
  #fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
    ];
  };

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

    #Enable closed source printer driver package
    services.printing.drivers = [ 
      pkgs.hplip
    ];

    #Enable networked printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

  #Scanner setup
  hardware.sane.enable = true;

  #Nix OS Manpages
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

  #Direct server link setup
  networking = {
    interfaces = {
      eno2 = {
        ipv4.addresses = [{
          address = "10.0.0.2";
          prefixLength = 24;
        }];
      };
    };
    wireless = {
      enable = true;
      networks = {
        "Ponto-3" = {
          psk = "Ponto-233603";
        };
      };
    };
  };

  #VPN things
  services.tailscale.enable = true;

  #Distro box
  virtualisation.podman = {
  enable = true;
  dockerCompat = true;
};

# Dynamic linking (impure)
#programs.nix-ld.enable = true;
}
