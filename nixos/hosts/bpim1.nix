{lib, pkgs, ...}: let
    sshKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE5gfkj8BLRw6KBWJhlKbr3PDPzEunDrLH70cLI2VQhlVNccUlcYebS8LdVkPyyzGh9xaSmn0zkIZq7kGZAeOy3rlSQz/sFQ0zRicfb6uD2GVndn51drJQPthdxypGhl24JClyN0knhrils4angEMZFkq+UZr8ku7/wJxiXSbiiO5TUU0L26Ijk2kCEcHlRrjMyANMznE3UYffqcwlLOd+udqOrPwC9Hk/DdyDRzLsXcPVE+6prgFg+vx5OEdvdAO6QuO1S1zxKq9hRDJ7mELEmWjmHjuvfEY+ZVRUaP7dFAejyr+I3GFshhZu7OkGtD5Gd0SF5P4jNzGobcEYaJsJ tina" ];
    password = "llamato";
  in {
  system.stateVersion = "25.05";

  #boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings = {
    eval-system = pkgs.system;
    sandbox = false;
    #sandbox-fallback = true;
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = sshKeys;
  };

  nixpkgs = {
    config = {
      allowUnsupportedSystem = true;
      allowEmulation = true;
    };
    buildPlatform.system = "x86_64-linux";
    hostPlatform.system = "armv7l-linux";
  };

  boot = {
    loader.generic-extlinux-compatible = {
      enable = true;
    };

    initrd = {
      includeDefaultModules = true;
      availableKernelModules = [ "mmc_block" ];
    };
    supportedFilesystems = lib.mkForce [ "btrfs" "cifs" "f2fs" "jfs" "ntfs" "reiserfs" "vfat" "xfs" ];
    kernelModules = [ "i2c-dev" "sunxi-ephy" ];
    kernelParams = [ "sunxi_emac.phy_interface=1" "sunxi_emac.rx_delay=3" "sunxi_emac.tx_delay=3" ];
  };

  hardware = {
    deviceTree.enable = false;
    enableRedistributableFirmware = true;
    graphics.enable = true;
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users = {
    root = {
      initialPassword = password;
      openssh.authorizedKeys.keys = sshKeys;
    };
  };

  environment.systemPackages = with pkgs; [
      git
      wget
      btop
      sl fastfetch
      ethtool mtr
      minicom
      ncdu_1 #(ncu mainline is broken on armv7l-linux)
      screen
    ];

  services = {
    openssh = {
      enable = true;
        settings = {
          KbdInteractiveAuthentication = lib.mkDefault false;
          PasswordAuthentication = lib.mkDefault true;
          PermitRootLogin = "yes"; # Debug / dev !!!
        };
      };
    };

  networking = {
    hostName = "nixBpiM1";
    useNetworkd = false;
    useDHCP = false;
  };

  systemd.network = {
    enable = true;

    networks."99-ethernet-default-dhcp" = {
      matchConfig.Name = "end0";
      networkConfig = {
        DHCP = "yes";
        MulticastDNS = true;
      };

      linkConfig = {
        RequiredForOnline = "routable";
        ActivationPolicy = "always-up";
      };
    };
  };

  systemd.services.bring-up-end0 = {
    description = "Bring up end0 network interface";
    after = ["network.target" "systemd-networkd.service"];
    wants = ["network.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip link set end0 up";
    };
    wantedBy = ["multi-user.target"];
  };
}