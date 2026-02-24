{
  pkgs,
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

  systemd.services.nixnasfancontroller = {
      description = "Western Digital MyCloud Home Duo Fan Controller";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "15s";
        User = "root";
      };
      script = ''
        while true; do
          CPU_IDLE=$(${pkgs.sysstat}/bin/mpstat 15 1 | tail -n 1 | ${pkgs.busybox}/bin/rev | cut -f1 -d" " | ${pkgs.busybox}/bin/rev | cut -f1 -d.)
          CPU_USAGE=$((100-$CPU_IDLE))
          MINIMUM_FAN_SPEED=20
          if [ $CPU_USAGE -le $MINIMUM_FAN_SPEED ]; then
            FAN_SPEED=20
          else
            FAN_SPEED=$CPU_USAGE
          fi
          echo $FAN_SPEED > /sys/devices/platform/980070d0.pwm/dutyRate3
          echo $CPU_USAGE  $FAN_SPEED
        done
      '';
    };
}