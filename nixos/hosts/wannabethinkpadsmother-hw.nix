{ config, lib, pkgs, modulesPath, ... }: {
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      kernelModules = [];
      availableKernelModules = [ "ohci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b24e021a-bbc1-4b1b-9886-303f580a1fb0";
      fsType = "f2fs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/12CE-A600";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

   swapDevices = [ {
    device = "/dev/disk/by-partuuid/e710d90d-a2dd-4a97-a751-3a9b60ce9373";
    randomEncryption.enable = true; 
  } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
