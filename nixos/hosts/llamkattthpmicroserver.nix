# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, inputs, ... }: {
  
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
    iperf iotop vnstat inetutils ethtool 
    btop ncdu sysstat iotop
    pciutils usbutils
    lm_sensors
    fastfetch sl
    rsync sshfs
    git
    monero-cli xmrig
    cifs-utils
    
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
        DNS = [ "192.168.3.1" ];
      };
    };

    # Usb 2.5gbit/s Main
    networks."30-usb-main" = {
      matchConfig.Name = "enp4s0u2c2";
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

  #Services
  services.openssh.enable = true;
}
