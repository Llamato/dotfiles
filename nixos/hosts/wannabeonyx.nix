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

  # The kernel's 2 MiB huge-page pool as one fixed root command, so the Strata run script can take
  # the pool when the server starts and hand it back when the server stops. Writing nr_hugepages is
  # root-only in the kernel ("A user with root privileges can dynamically allocate more or free some
  # persistent huge pages", kernel HugeTLB admin guide), so this one command is what the sudoers rule
  # below allows without a password. It is a store path: it changes with every rebuild, and sudoers is
  # rebuilt together with it.
  strataHugepages = pkgs.writeShellScriptBin "strata-hugepages" ''
    # strata-hugepages <pages>: set the 2 MiB pool, then print what the kernel actually gave.
    # strata-hugepages 0 hands the whole pool back. IQ3_XXS asks for 20464 pages (40 GiB), IQ3_S for 23983.
    N=$1
    [ -n "$N" ] || { echo "usage: strata-hugepages <pages>   (0 frees the pool)"; exit 2; }
    P=/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
    have=$(cat $P)
    if [ "$N" -gt "$have" ]; then
      # A runtime reserve lands short on a machine that has been up for a while: each 2 MiB page needs
      # a contiguous block. Drop the reclaimable page cache and defragment first, then ask.
      sync
      echo 3 > /proc/sys/vm/drop_caches
      echo 1 > /proc/sys/vm/compact_memory
    fi
    echo $N > $P
    got=$(cat $P)
    echo "2 MiB pool: asked $N, got $got ($(( got * 2 / 1024 )) GiB)"
    if [ "$got" -ne "$N" ]; then
      echo "warning: the kernel gave $got of $N pages (fragmentation, or not enough free RAM)."
      echo "         MAP_HUGETLB is all-or-nothing: an arena that needs $N pages falls back to 4 KiB pages."
      exit 1
    fi
  '';
in
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      timeout = 5;
    };

    kernelParams = [
      "default_hugepagesz=2M"
      "hugepagesz=2M"
      # Strata's expert arena maps MAP_HUGETLB, which is all-or-nothing: the pool has to hold the whole
      # mapping or the arena falls back to 4 KiB pages. Qwen3.8-Flash-Next IQ3_XXS asks for 20464 2 MiB
      # pages (40 GiB), IQ3_S for 23983. Nothing is reserved at boot: run-iq3_xxs-huge-7900xtx.sh takes
      # 24576 pages when the server starts and frees them when it stops (sudo strata-hugepages, see
      # security.sudo.extraRules below). A boot reserve is the deterministic version of the same thing -
      # it cannot land short on fragmentation, but the RAM is held even with no server running. To go
      # back to it, this line is "hugepages=24576" or "hugepages=32768".
      "hugepages=0"
      "hugepagesz=1G"
      "hugepages=0"
      "iommu=pt"
    ];
  
    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 200;
      "kernel.numa_balancing" = 0;
      };

    supportedFilesystems = [
      "bcachefs"
      "btrfs"
      "xfs"
      "ntfs"
      "bitlocker"
      "exfat"
      "vfat"
      "f2fs"
    ];

    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    kernelModules = [
      "v4l2loopback"
    ];

    extraModprobeConfig = ''
      options v4l2loopback devices=2 video_nr=1,2 card_label="OBS Cam, Virt Cam" exclusive_caps=1
    '';

    tmp = {
      cleanOnBoot = true;
      useTmpfs = false;
    };

    binfmt.emulatedSystems = [
      "aarch64-linux"
      "armv7l-linux"
    ];
  };
  security.polkit.enable = true;

  # Strata page-locks its n-gram (PLE) table: 26.8 GiB on Qwen3.8-Flash-Next IQ3_XXS. The engine can
  # raise its own soft limit but never the hard one, so both have to come from PAM - 8 MiB (this
  # PC's default) locks none of it. The engine reads the table either way; the lock was measured up
  # to 6% faster decode (Strata engine #4671). Takes effect on the next login, not for sessions
  # already open.
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "hard";
      item = "memlock";
      value = "unlimited";
    }
  ];

  # The only root command the Strata run scripts may use, and the only one without a password.
  # Without it the runner would sit on a sudo password prompt at every start (sudo -n asks for one
  # on this PC today).
  security.sudo.extraRules = [
    {
      users = [ "tina" ];
      runAs = "root";
      commands = [
        {
          command = "${strataHugepages}/bin/strata-hugepages";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  networking.hostName = "wannabeonyx";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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

  #Wireshark
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
    strataHugepages
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
    f2fs-tools
    cinny
    fortune
    gzdoom

    jetbrains.clion
    jetbrains.pycharm
    android-studio
    android-tools

    mumble

    (pkgs.callPackage ../packages/serial-tether/package.nix { })
  ];

  #No automatic firmware updates
  services.fwupd.enable = false;

  #Space Mouse driver
  systemd.user.services.spacenavd.enable = true;

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

  #Local ai
  #services.strata.enable = true;

  # Dynamic linking (impure) (Not working?)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      libxml2
      ncurses
      clangrt
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
