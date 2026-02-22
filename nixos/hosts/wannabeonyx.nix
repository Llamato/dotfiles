# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:
{

  # Lix (What the hell is lix?)
  #nix.package = pkgs.lixPackageSets.stable.lix;

  # Bootloader.
  /*nixos-boot = {
    enable = true;
    duration = 5.0;
  };*/

  boot = {
    /*plymouth = {
      enable = true;
      #theme = "rings";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];*/

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    timeout = 0;
    };
  };

  # Extra filesystems
  boot.supportedFilesystems = [
    "bcachefs"
    "xfs"
    "ntfs"
    "bitlocker"
    "exfat"
    "vfat"
  ];

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

  #Enable memtest86 option in bootloader
  #boot.loader.systemd-boot.memtest86.enable = true;

  #Enable Architecture emulation in QEMU
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv7l-linux"
    "riscv64-linux"
  ];

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
                      { "application.process.binary" = "webcord"; }
                      { "application.process.binary" = "firefox"; }
                      { "application.process.binary" = "vesktop"; }
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

  # Enable Kwallet for GPG
  security.pam.services.kwallet.enable = true;

  # Enable Docker
  virtualisation.docker.enable = true;

  users.extraGroups.docker.members = [ "tina" ]; # Bad because this is effectively equivalent to being root according to https://nixos.wiki/wiki/Docker (dla: 12.10.2025)
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
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
        "ssh-falcon1024 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 tina@wannabeonyx"
        "ssh-falcon512 AAAADXNzaC1mYWxjb241MTIAAAOBCYselVfYAiMNMr/352O5W05OFNCDgR/VQOKtihMduSTDbZFYUxXU+b8Kh3IBg9A3aw0FcMp6PayAiu5oV5WL0zdoivJP1pGakIKUdFhdFCH9xtfIiJGQP9b7X8dpKtaYXF0TnVgVNcHqi13W/1AX4bQtiJ92WFoTcUklFy7SuL5M1vmmKM+olOoWXdChD+wW49ffqaTmyJUT5PtVCdIj+aCKDiWsxl+X12Z6NGq5LcteXbeqtZCytymU6RGKyHyswpb+CVQzCdA2YdjzKcy7pRzKJqzUJ9JRTHaAUUQ7PlgGnfjakGXC4bMg7xLEw/CUBaVCOqqFJFJdxwADUo52LPK3gdZ2KrM55GZgYhxG8FMDChxYsXAzhUQmPgSGX8pDZfTUcMoBEjGRWMB7Q6OELL8DtiRZW+lG4zFhHlYV/gk4A/NSdIR6ikqIbRroqlTcl1q13JIfRl8STJbQ5VDPWUWrSYLQPRh9gsObblERZq6QKGjfrtkw5APBEHtCKTavCVeN6kKiC9dPPfbFYumt67bOrIkLmvpgjA0YGlKiCgj1l7rtS5pp5hAUymxlVRYoX+Usk4rB6LVJtD74sUpn7u6GioG365gBZ2HOdn0WT0eZbceJQ1i7qCuilqAfDN4rwVGNTS3FHoa1bgo9OQGWu6ArHA6ryQ6JSqQ1qibGDJGfPdjHxOPKnVkwN/TG+g29EfCAEKd0wo+J3AkKrWF58lgfx7jOyPrWCXh2EYC5cx50ujL78e1C4gephmZb7/ZzCqb02KuUMEqr0Tvn+wupWXhoXtVdONYHWJlgTYm8aHXA/IhyNWCHFGl0rELlXuxWlRXrFmTq73ccBRHrZhBtxV/yg6d7Pr65txKi3nzJD8H56UNPhIqJrk0jr7HsZbhXwAQd7KhJwDcTAj7oTkEtoYhHtQCuigvssKIqg/6KMF4KjmKLuggt+VidBRYFh/fo7CWHdDdGoS78W8LmCiyv4JrMxnBCA5aKUDEXq8rauuHKkO8wAD6N98BORNazEKC5fKxDYAHYW/bYYWQofaSgygx/daYVvZ/dDyDGxkIUBUAKjSsCLEQd+M2qvpv/QMgOYUQhWy/KOgaDgzCX6KQDOBscJVIBp9DWWJuh0dGuliCCgbP2CMb+VlonMY/dJX00Vnb62nhmRKyi56UHTb1LxlgVtztpVRIphbKrfZlCOE3v tina@wannabeonyx"
      ];
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Install steam
  #programs.ßsteam.enable = true;

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
      obs-vaapi # optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    dig
    spacenavd
    libspnav
    dislocker
    qemu
    pwvucontrol
    powertop
    ryzen-monitor-ng
    sg3_utils
    vnstat iperf3 iotop mission-center ethtool inetutils net-tools mtr
    cifs-utils
    archivemount
    git
    kdePackages.kate
    thunderbird
    discord vencord vesktop
    ffmpeg
    cool-retro-term
    sl
    kdePackages.kdenlive
    rawtherapee
    vlc
    gimp3
    telegram-desktop
    fastfetch
    cpufetch
    gpufetch
    python3
    libreoffice-qt6-fresh
    simple-scan
    gocr
    unpaper
    netpbm
    rnote
    wayland
    blueman
    obsidian
    virt-manager
    gparted
    zip
    unzip
    xz
    rsync sshfs
    stress
    hardinfo2
    qdiskinfo
    tree
    nix-tree
    element-desktop # cinny-desktop
    texlive.combined.scheme-full
    p7zip
    hexedit
    kdePackages.ark
    wlvncc
    monero-gui
    bitcoin
    docker-compose
    android-file-transfer
    mtpfs f2fs-tools
    exiftool
    cinny
    fortune
    
    #Tina's packages
    inputs.gcalc.packages.${pkgs.system}.default
    #inputs.gcrypt.packages.${pkgs.system}.default
    inputs.gbounce.packages.${pkgs.system}.default
    inputs.stenc.packages.${pkgs.system}.stenc
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "mbedtls-2.28.10"
  ];

  #No automatic firmware updates
  services.fwupd.enable = false;

  #Space Mouse driver
  systemd.user.services.spacenavd.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

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
  users.groups.libvirtd.members = [ "tina" ];
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "start";
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      /*
        ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
          }).fd];
        };
      */
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

      eno1 = {
        # 2.5gbit/s local network
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "192.168.3.21";
            prefixLength = 24;
          }
        ];
      };

      eno2 = {
        # 10gbit/s direct connect
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.20.30.2";
            prefixLength = 24;
          }
        ];
      };
    };

    /*wireless = {
      enable = false;
      networks = {
        "Ponto-3" = {
          psk = "ponto-233603";
        };
      };
    };*/

    #How do we get on the internet
    defaultGateway = {
      address = "192.168.3.1";
      interface = "eno1";
    };
    nameservers = [
      "192.168.3.1"
    ];
  };

  #VPN things
  #  services.tailscale.enable = true;

  # Dynamic linking (impure)
  #programs.nix-ld.enable = true;
}
