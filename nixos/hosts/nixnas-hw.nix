{
  ...
} :
{
  # Boot
  boot.loader.grub.enable = false;
  boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1;
  boot.kernelParams = [ # Does this do anything?
    "systemd.unified_cgroup_hierarchy=0"
    "SYSTEMD_CGROUP_ENABLE_LEGACY_FORCE=1"
  ];

  # Filesystems
  fileSystems."/" = {
    device = "/dev/md1";
    fsType = "ext4";
  };

  # Watchdog timer handling demon
  systemd.services.watchdog = {
    description = "Write V to /dev/watchdog0 once at boot to disable the watchdog timer";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };

    script = ''
      #!/bin/sh
      echo "V" > /dev/watchdog0
    '';
  };
  
}