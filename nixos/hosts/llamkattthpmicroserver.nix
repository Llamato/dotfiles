# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, inputs, ... }: let
  startsWith = with builtins; pattern: str: (length (match "^(${pattern}).*" str)) > 0;

  endsWith = with builtins; pattern: str: (length (match "*.^(${pattern})" str)) > 0;

  isSshKey = key: startsWith "ssh-" key;

  makeUser = name: {keys ? [], useSystemKeys ? false, useUserKeys ? false}: let
    gtoPath = pstr: /. + pstr;
    homeDir = "/mnt/raid/home/${name}";
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
in {
  
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.efiInstallAsRemovable = false;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  system.stateVersion = "25.05"; # Did you read the comment?

#Tinas edits
  #boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ext4" ];

  networking = {
    hostName = "LlamKatttHpMicroServer";
    networkmanager.enable = false;
    hostId = "7eeb63ab";
    extraHosts = ''127.0.0.1 homelab.llamato.dev'';
  };

  time.timeZone = "Europe/Berlin";

  users = {
    defaultUserHome = "/mnt/raid/home";
    groups = {
      jamlytics = {};
    };
    users = {

      tina = {
        isNormalUser = true;
        home = "/mnt/raid/home/tina";
        extraGroups = [ "networkmanager" "wheel" "jamlytics" ];
        openssh.authorizedKeys.keys = [
          "ssh-falcon1024 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 tina@wannabeonyx"
          "ssh-falcon512 AAAADXNzaC1mYWxjb241MTIAAAOBCYselVfYAiMNMr/352O5W05OFNCDgR/VQOKtihMduSTDbZFYUxXU+b8Kh3IBg9A3aw0FcMp6PayAiu5oV5WL0zdoivJP1pGakIKUdFhdFCH9xtfIiJGQP9b7X8dpKtaYXF0TnVgVNcHqi13W/1AX4bQtiJ92WFoTcUklFy7SuL5M1vmmKM+olOoWXdChD+wW49ffqaTmyJUT5PtVCdIj+aCKDiWsxl+X12Z6NGq5LcteXbeqtZCytymU6RGKyHyswpb+CVQzCdA2YdjzKcy7pRzKJqzUJ9JRTHaAUUQ7PlgGnfjakGXC4bMg7xLEw/CUBaVCOqqFJFJdxwADUo52LPK3gdZ2KrM55GZgYhxG8FMDChxYsXAzhUQmPgSGX8pDZfTUcMoBEjGRWMB7Q6OELL8DtiRZW+lG4zFhHlYV/gk4A/NSdIR6ikqIbRroqlTcl1q13JIfRl8STJbQ5VDPWUWrSYLQPRh9gsObblERZq6QKGjfrtkw5APBEHtCKTavCVeN6kKiC9dPPfbFYumt67bOrIkLmvpgjA0YGlKiCgj1l7rtS5pp5hAUymxlVRYoX+Usk4rB6LVJtD74sUpn7u6GioG365gBZ2HOdn0WT0eZbceJQ1i7qCuilqAfDN4rwVGNTS3FHoa1bgo9OQGWu6ArHA6ryQ6JSqQ1qibGDJGfPdjHxOPKnVkwN/TG+g29EfCAEKd0wo+J3AkKrWF58lgfx7jOyPrWCXh2EYC5cx50ujL78e1C4gephmZb7/ZzCqb02KuUMEqr0Tvn+wupWXhoXtVdONYHWJlgTYm8aHXA/IhyNWCHFGl0rELlXuxWlRXrFmTq73ccBRHrZhBtxV/yg6d7Pr65txKi3nzJD8H56UNPhIqJrk0jr7HsZbhXwAQd7KhJwDcTAj7oTkEtoYhHtQCuigvssKIqg/6KMF4KjmKLuggt+VidBRYFh/fo7CWHdDdGoS78W8LmCiyv4JrMxnBCA5aKUDEXq8rauuHKkO8wAD6N98BORNazEKC5fKxDYAHYW/bYYWQofaSgygx/daYVvZ/dDyDGxkIUBUAKjSsCLEQd+M2qvpv/QMgOYUQhWy/KOgaDgzCX6KQDOBscJVIBp9DWWJuh0dGuliCCgbP2CMb+VlonMY/dJX00Vnb62nhmRKyi56UHTb1LxlgVtztpVRIphbKrfZlCOE3v tina@wannabeonyx"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmuHyyOtAxG1GSuqIoeeGfV8XfLQGzS6zalYuAumlD+ tina_modern"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE5gfkj8BLRw6KBWJhlKbr3PDPzEunDrLH70cLI2VQhlVNccUlcYebS8LdVkPyyzGh9xaSmn0zkIZq7kGZAeOy3rlSQz/sFQ0zRicfb6uD2GVndn51drJQPthdxypGhl24JClyN0knhrils4angEMZFkq+UZr8ku7/wJxiXSbiiO5TUU0L26Ijk2kCEcHlRrjMyANMznE3UYffqcwlLOd+udqOrPwC9Hk/DdyDRzLsXcPVE+6prgFg+vx5OEdvdAO6QuO1S1zxKq9hRDJ7mELEmWjmHjuvfEY+ZVRUaP7dFAejyr+I3GFshhZu7OkGtD5Gd0SF5P4jNzGobcEYaJsJ tina" 
          ];
      };

      quinten = makeUser "quinten" {keys = [
        "ssh-falcon1024 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 quinten@computerq"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCqf7igKE0dymwQUoBV0Wrxh7GTMb4oU6KDJMNzTQ4+"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYIsN35+EtXZ78tWF3lDzb0sTQx9TLvtyQMa5tt/Hne root@chaotic" 
      ];};

      amber = makeUser "amber" {keys = [ 
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+kNski6X9Vot6gej9aNj0b+CCyjC19gCAQGOGOvsc8"
      ];};

      romana = makeUser "romana" {keys = [ 
           "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM30of3vRzm2aB5f+b9HVVNKh811emm7ZD4OW9v2tfcx u0_a468@localhost" 
           "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAING7VPuszU2P1fYm/h8ZTywzfNhHHPZFFbL2pUdIQfSq flash@bios"
      ];};

      zvit = makeUser "zvit" {keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLTCoAAHoImrR+FdiWmGJDD7ke8MmiTaZukANS/uPvQ"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEePG3qRnXD2QqpWLM80nBls+9T9kX5U3IKJn3UdTSe"
      ];};

      xlr8 = makeUser "xlr8" {keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDjXDBnCD0BKcmTZWigTv8IKOyaR5ygMbtl0CXg9IgW3"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIv62sAxqnextBcPh7IDV8rcCDt0Bd4m9fm2q4pjFuKJ"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6fxDC8yCvi0q0Hzc4JEirbZiJtZZ6oRfScGYYCRqLo"
      ];};

      kattt = {
        isNormalUser = true;
	      home = "/mnt/raid/home/kattt";
        password = "KatttInTheVat";
        #openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE5gfkj8BLRw6KBWJhlKbr3PDPzEunDrLH70cLI2VQhlVNccUlcYebS8LdVkPyyzGh9xaSmn0zkIZq7kGZAeOy3rlSQz/sFQ0zRicfb6uD2GVndn51drJQPthdxypGhl24JClyN0knhrils4angEMZFkq+UZr8ku7/wJxiXSbiiO5TUU0L26Ijk2kCEcHlRrjMyANMznE3UYffqcwlLOd+udqOrPwC9Hk/DdyDRzLsXcPVE+6prgFg+vx5OEdvdAO6QuO1S1zxKq9hRDJ7mELEmWjmHjuvfEY+ZVRUaP7dFAejyr+I3GFshhZu7OkGtD5Gd0SF5P4jNzGobcEYaJsJ tina" ];
      };

    };
  };
  environment.systemPackages = with pkgs; [
    screen
    iperf iotop vnstat inetutils
    lm_sensors
    btop
    fastfetch
    sl
    rsync git
    monero-cli xmrig
    nixd

    #Reverse eng
    #readelf
    python3
    nmap
    dtc
    
    #custom
    inputs.nixpkgs-llamato.legacyPackages.${pkgs.system}.bun-baseline
  ];

  #Networking
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
        TransmitHashPolicy = "layer2+3";                                                           
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

    networks."20-bond0" = {
      matchConfig.Name = "bond0";
      networkConfig = {
        Address = [ "192.168.3.11/24" ];
        Gateway = "192.168.3.1";
        DNS = [ "1.1.1.1" "1.0.0.1" ];
      };
    };

    # Usb 2.5gbit/s Main
    networks."30-usb-main" = {
      matchConfig.Name = "enp4s0u1c2";
      networkConfig = { 
        Address = [ "10.20.30.4/24" ];
        #Gateway = "10.20.30.1";
      };
      dhcpV4Config = {
        RouteMetric = 2000; # higher priority than bond
      };
    };
  };

  #networkmanager.enable = lib.mkForce false;
  networking.firewall.enable = false;  
  networking.useNetworkd = true;
  networking.useDHCP = false;
}
