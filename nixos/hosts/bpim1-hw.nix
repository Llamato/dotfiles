{ pkgs, lib, ... }: {
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    initrd = {
      includeDefaultModules = true;
      availableKernelModules = [ "mmc_block" ];
    };
    kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1;
    kernelParams = [ # Does this do anything?
      "systemd.unified_cgroup_hierarchy=0"
      "SYSTEMD_CGROUP_ENABLE_LEGACY_FORCE=1"
    ];
    supportedFilesystems = lib.mkForce [ "btrfs" "cifs" "f2fs" "jfs" "ntfs" "reiserfs" "vfat" "xfs" ];
    kernelModules = [ "i2c-dev" "sunxi-ephy" "gpio-sunxi" "spi-sun4i" "spidev" ];
  };

  # Filesystems
  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
  };
  
  fileSystems."/boot" = {
    device = "/dev/mmcblk0p1";
    fsType = "vfat";
  };

  environment.systemPackages = with pkgs; [
    libgpiod
  ];
}