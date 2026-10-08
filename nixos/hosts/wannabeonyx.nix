# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:
let
  semisecrets = (import ../../semisecrets.nix { inherit config lib pkgs; });
in
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      timeout = 5;
    };
  };

  # Extra filesystems
  boot.supportedFilesystems = [
    "bcachefs"
    "btrfs"
    "xfs"
    "ntfs"
    "bitlocker"
    "exfat"
    "vfat"
    "f2fs"
  ];

  # Extra Kernel modules
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  #Video for linux loopback. Screen share, obs, etc...
  boot.kernelModules = [
    "v4l2loopback"
  ];

  # OBS virtual camera
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=2 video_nr=1,2 card_label="OBS Cam, Virt Cam" exclusive_caps=1
  '';

  # Clean temp dir on boot
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = false;

  # Enable Architecture emulation in QEMU
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv7l-linux"
    "riscv64-linux"
  ];

  security.polkit.enable = true;

  networking.hostName = "wannabeonyx";

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

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.flatpak.enable = true;

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
    alsa.support32Bit = true;
    jack.enable = true;
    wireplumber = {
      enable = true;
      extraConfig = {
        "11-bluetooth-policy" = {
          "wireplumber.settings" = {
            "bluez5.profile" = "a2dp-sink";
          };
        };
      };
    };
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

  # Enable Kwallet for GPG
  security.pam.services.kwallet.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmuHyyOtAxG1GSuqIoeeGfV8XfLQGzS6zalYuAumlD+ tina_modern"
    ];
    tina = {
      isNormalUser = true;
      description = "Tina";
      extraGroups = [
        "jamlytics"
        "users"
        "networkmanager"
        "wheel"
        "scanner"
        "lp"
        "docker"
      ];
      openssh.authorizedKeys.keys = semisecrets.semisecrets.tina.keys.ssh;
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  #nixpkgs configuration
  nixpkgs.config = {
    allowUnfree = true;
    allowEmulation = true;
  };

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

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
    dumpcap.enable = true;
    usbmon.enable = true;
  };
  users.groups.wireshark.members = [ "tina" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    dig
    libspnav
    dislocker
    qemu
    pwvucontrol
    powertop
    ryzen-monitor-ng
    sg3_utils
    archivemount
    discord
    cool-retro-term
    sl
    kdePackages.kdenlive
    telegram-desktop
    fastfetch
    cpufetch
    gpufetch
    python3
    unpaper
    netpbm
    wayland
    blueman
    obsidian
    virt-manager
    gparted
    gptfdisk
    zip
    unzip
    xz
    rsync
    sshfs
    hardinfo2
    qdiskinfo
    tree
    nix-tree
    element-desktop
    cinny-desktop
    hexedit
    kdePackages.ark
    monero-gui
    bitcoin
    android-file-transfer
    mtpfs
    f2fs-tools
    cinny
    fortune
    gzdoom

    jetbrains.clion
    jetbrains.pycharm
    android-studio
    android-tools

  ];

  #No automatic firmware updates
  services.fwupd.enable = false;

  #Space Mouse driver
  systemd.user.services.spacenavd.enable = true;

  #Kate wakatime
  #services.kate-wakatime.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  #Disable firewall
  networking.firewall.enable = false;

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

    wireless = {
      enable = false;

    };

    #How do we get on the internet
    defaultGateway = {
      address = "192.168.3.1";
      interface = "eno1";
    };
    nameservers = [
      "192.168.3.1"
    ];
  };

  #SSH access
  services.openssh = {
    enable = true;
    settings.AllowUsers = [
      "root"
      "tina"
    ];
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "yes";
  };

  #VPN things
  services.tailscale.enable = true;

  # Dynamic linking (impure)
  #programs.nix-ld.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
