# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:
{

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/usb-USB_SanDisk_3.2Gen1_0101b46449c6505a1415e87b396199107099b9cb7c9acb7303efb7db9f60d9514a25000000000000000000003a0578a3ff865000955581077fac1d28-0:0";
  boot.loader.grub.useOSProber = true;
  
  # Extra filesystems
  boot.supportedFilesystems = [
    "xfs"
    "ntfs"
    "bitlocker"
    "exfat"
    "vfat"
    "zfs"
  ];

  boot.zfs.extraPools = ["new-pool"];

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tina = {
    isNormalUser = true;
    description = "tina";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    screen
    ledmon
    wget
    p7zip
    git
    ethtool
    inetutils iperf3 vnstat
    gptfdisk
    btop
    fastfetch
    megacli
    ipmitool
    pciutils
    lshw
    smartmontools
    e2fsprogs
    minicom
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable custom fan controller
  services.dellfancontroller.enable = true;

  networking.hostName = "wannabeinthebasementRusb";
  networking.hostId = "00006301";
  networking.firewall.enable = false;  
  networking.useNetworkd = true;
  networking.useDHCP = false;
  systemd.network = {
    enable = true;

    # LACP bond setup
    netdevs."10-bond0" = {
      netdevConfig = {                                                                             
        Name = "bond0";                                                                            
        Kind = "bond";                                                                             
      };   

      bondConfig = {                                                                               
        Mode = "802.3ad";                                                                          
        TransmitHashPolicy = "layer3+4";                                                           
        MIIMonitorSec = "1s";                                                                                                                                    
      };                                                                                             
    };                                                                                             
                                                                                                   
    # Bond slaves                                                                                  
    networks."10-eno1" = {                                                                         
      matchConfig.Name = "eno1";                                                                   
      networkConfig.Bond = "bond0";                                                                
    };                                                                                             
                                                                                                   
    networks."10-eno2" = {
      matchConfig.Name = "eno2";
      networkConfig.Bond = "bond0";
    };

    networks."10-eno3" = {                                                                         
      matchConfig.Name = "eno3";                                                                   
      networkConfig.Bond = "bond0";                                                                
    };                                                                                             
                                                                                                   
    networks."10-eno4" = {
      matchConfig.Name = "eno4";
      networkConfig.Bond = "bond0";
    };

    # Bond IP config (static)
    networks."20-bond0" = {
      matchConfig.Name = "bond0";
      networkConfig = {
        Address = [ "192.168.3.14/24" ];
        Gateway = "192.168.3.1";
        DNS = [ "1.1.1.1" "1.0.0.1" ];
      };
    };

    # Fibre 10gbit/s Main
    networks."30-fibre-main" = {
      matchConfig.Name = "enp67s0f0";
      networkConfig = { 
        Address = [ "10.20.30.3/24" ];
        #Gateway = "10.20.30.1";
      };

      dhcpV4Config = {
        RouteMetric = 2000; # higher priority than bond
      };
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
