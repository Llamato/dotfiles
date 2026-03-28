{ config, lib, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.device = "/dev/sda";
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.initrd.availableKernelModules = [ "xhci_pci" "usb_storage" "sd_mod" "sdhci_acpi" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [
    "bcachefs"
    "xfs"
    "ntfs"
    "bitlocker"
    "exfat"
    "vfat"
    "apfs"
  ];  


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/cbe035aa-c7db-44e2-b230-45f1cce5169f";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/362001e1-581c-44a2-9b87-ab1235257aee"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
