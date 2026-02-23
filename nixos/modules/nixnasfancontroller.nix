{
  lib,
  config,
  ...
}:
{
  options.services.nixnasfancontroller = {
    enable = lib.mkEnableOption "Western Digital MyCloud Home Duo Fan Controller";
  };

  config = lib.mkIf (config.services.nixnasfancontroller or { }).enable {

    systemd.services.nixnasfancontroller = {
      description = "Western Digital MyCloud Home Duo Fan Controller";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        script = ''
          while true; do
              CPU_IDLE=$(mpstat | tail -n 1 | rev | cut -f1 -d" " | rev | cut -f1 -d.)
              CPU_USAGE=$((100-$CPU_IDLE))
              echo $CPU_USAGE > /sys/devices/platform/980070d0.pwm/dutyRate3
              sleep 15
          done
        '';
        Restart = "always";
        RestartSec = "15s";
        User = "root";
      };
    };
  };
}