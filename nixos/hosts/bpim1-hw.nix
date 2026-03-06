{ pkgs, ... }: {
  boot.loader.grub.enable = false;
  boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1;
  boot.kernelParams = [ # Does this do anything?
    "systemd.unified_cgroup_hierarchy=0"
    "SYSTEMD_CGROUP_ENABLE_LEGACY_FORCE=1"
  ];

  # Filesystems
  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/mmcblk0p1";
    fsType = "vfat";
  };
}