# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, ... }:
let
  startsWith = with builtins; pattern: str: (length (match "^(${pattern}).*" str)) > 0;

  endsWith = with builtins; pattern: str: (length (match "*.^(${pattern})" str)) > 0;

  isSshKey = key: startsWith "ssh-" key;

  makeUser = name: {keys ? [], useSystemKeys ? false, useUserKeys ? false}: let
    gtoPath = pstr: /. + pstr;
    homeDir = "/home/${name}";
    userKeyDir = homeDir + "/" + ".ssh";

    getKeyFiles = with builtins; dir:  map (file: 
    readFile file) (lib.fileset.fileFilter (file: endsWith ".pub" file.name) dir);

    systemKeyFiles = username: let keyDir = "/mnt/raid/home/tina/dotfiles/keys"; 
    in lib.fileset.fileFilter (file: startsWith username file.name) keyDir;

    userKeyFiles = let keyDir = homeDir + "/" + ".ssh"; 
    in getKeyFiles userKeyDir;

    userKeys = with builtins; filter (key: isSshKey key) (userKeyFiles name);
    systemKeys = with builtins; filter (key isSshKey key) systemKeyFiles;
    keyStrings = with builtins; map (key: 
      if pathExists (gtoPath key) then 
        readFile (gtoPath key) 
      else if isSshKey key then 
        key
      else
        throw "keyfile does not exist or key format is invalid"
      ) keys;
  in {
    isNormalUser = true;
    extraGroups = [ "jamlytics" "users" ];
    home = homeDir;
    createHome = true;
    openssh.authorizedKeys.keys = with lib; 
      keyStrings ++ optionals useSystemKeys systemKeys ++ optionals useUserKeys userKeys;
  };
in
{

  # Extra filesystems
  boot.supportedFilesystems = [
    "xfs"
    "ntfs"
    "bitlocker"
    "exfat"
    "vfat"
    "zfs"
    "f2fs"
  ];

  #boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  boot.zfs.extraPools = ["stripe-pool"];

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
  users.users = {
  tina = {
    isNormalUser = true;
    description = "tina";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmuHyyOtAxG1GSuqIoeeGfV8XfLQGzS6zalYuAumlD+ tina_modern"
        "ssh-falcon1024 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 tina@wannabeonyx"
        "ssh-falcon512 AAAADXNzaC1mYWxjb241MTIAAAOBCYselVfYAiMNMr/352O5W05OFNCDgR/VQOKtihMduSTDbZFYUxXU+b8Kh3IBg9A3aw0FcMp6PayAiu5oV5WL0zdoivJP1pGakIKUdFhdFCH9xtfIiJGQP9b7X8dpKtaYXF0TnVgVNcHqi13W/1AX4bQtiJ92WFoTcUklFy7SuL5M1vmmKM+olOoWXdChD+wW49ffqaTmyJUT5PtVCdIj+aCKDiWsxl+X12Z6NGq5LcteXbeqtZCytymU6RGKyHyswpb+CVQzCdA2YdjzKcy7pRzKJqzUJ9JRTHaAUUQ7PlgGnfjakGXC4bMg7xLEw/CUBaVCOqqFJFJdxwADUo52LPK3gdZ2KrM55GZgYhxG8FMDChxYsXAzhUQmPgSGX8pDZfTUcMoBEjGRWMB7Q6OELL8DtiRZW+lG4zFhHlYV/gk4A/NSdIR6ikqIbRroqlTcl1q13JIfRl8STJbQ5VDPWUWrSYLQPRh9gsObblERZq6QKGjfrtkw5APBEHtCKTavCVeN6kKiC9dPPfbFYumt67bOrIkLmvpgjA0YGlKiCgj1l7rtS5pp5hAUymxlVRYoX+Usk4rB6LVJtD74sUpn7u6GioG365gBZ2HOdn0WT0eZbceJQ1i7qCuilqAfDN4rwVGNTS3FHoa1bgo9OQGWu6ArHA6ryQ6JSqQ1qibGDJGfPdjHxOPKnVkwN/TG+g29EfCAEKd0wo+J3AkKrWF58lgfx7jOyPrWCXh2EYC5cx50ujL78e1C4gephmZb7/ZzCqb02KuUMEqr0Tvn+wupWXhoXtVdONYHWJlgTYm8aHXA/IhyNWCHFGl0rELlXuxWlRXrFmTq73ccBRHrZhBtxV/yg6d7Pr65txKi3nzJD8H56UNPhIqJrk0jr7HsZbhXwAQd7KhJwDcTAj7oTkEtoYhHtQCuigvssKIqg/6KMF4KjmKLuggt+VidBRYFh/fo7CWHdDdGoS78W8LmCiyv4JrMxnBCA5aKUDEXq8rauuHKkO8wAD6N98BORNazEKC5fKxDYAHYW/bYYWQofaSgygx/daYVvZ/dDyDGxkIUBUAKjSsCLEQd+M2qvpv/QMgOYUQhWy/KOgaDgzCX6KQDOBscJVIBp9DWWJuh0dGuliCCgbP2CMb+VlonMY/dJX00Vnb62nhmRKyi56UHTb1LxlgVtztpVRIphbKrfZlCOE3v tina@wannabeonyx"
    ];
  };
  
  romana = makeUser "romana" {keys = [ 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM30of3vRzm2aB5f+b9HVVNKh811emm7ZD4OW9v2tfcx u0_a468@localhost" 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAING7VPuszU2P1fYm/h8ZTywzfNhHHPZFFbL2pUdIQfSq flash@bios"
  ];};

  zvit = makeUser "zvit" {keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLTCoAAHoImrR+FdiWmGJDD7ke8MmiTaZukANS/uPvQ"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEePG3qRnXD2QqpWLM80nBls+9T9kX5U3IKJn3UdTSe"
  ];};
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
    rsync sshfs
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
    ncdu sysstat iotop
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

  networking.hostName = "wannabeinthebasement";
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
        DNS = [ "192.168.3.1" ];
      };
    };

    # 10gbit/s Fibre Main
    networks."30-fibre-main" = {
      enable = false;
      matchConfig.Name = "enp67s0f0";
      networkConfig = { 
        Address = [ "10.20.30.5/24" ];
        #Gateway = "10.20.30.1";
      };
    };

    # 10gbit/s Copper Main
    networks."40-copper-main" = {
      matchConfig.Name = "enp67s0f1";
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
