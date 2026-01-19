{ pkgs, lib, config, ... }:

let
  ipmitool = pkgs.ipmitool;
  
  dellfancontroller = pkgs.writeShellScriptBin "dellfancontroller" ''
    #!/bin/sh
    LOWTEMP=50
    MIDTEMP=60
    HIGHTEMP=80

    LOWSPEED=0x06
    MIDSPEED=0x20
    HIGHSPEED=0x64

    while true; do
        HIGHESTTEMP=$(${ipmitool}/bin/ipmitool sdr type temperature | ${pkgs.gnugrep}/bin/grep -Po '\d+(?= degrees C)' | sort -n | tail -1)
        if [ -z "$HIGHESTTEMP" ]; then
            echo "No temperature data found"
            sleep 15
            continue
        fi
        
        if [ $HIGHESTTEMP -ge $HIGHTEMP ]; then
            ${ipmitool}/bin/ipmitool raw 0x30 0x30 0x02 0xff $HIGHSPEED
        elif [ $HIGHESTTEMP -ge $MIDTEMP ]; then
            ${ipmitool}/bin/ipmitool raw 0x30 0x30 0x02 0xff $MIDSPEED
        elif [ $HIGHESTTEMP -le $LOWTEMP ]; then
            ${ipmitool}/bin/ipmitool raw 0x30 0x30 0x02 0xff $LOWSPEED
        fi
        
        sleep 15
    done
  '';
in
{
  options.services.dellfancontroller = {
    enable = lib.mkEnableOption "Dell PowerEdge fan controller";
  };

  config = lib.mkIf (config.services.dellfancontroller or {}).enable {
    environment.systemPackages = [
      pkgs.ipmitool
      dellfancontroller
    ];

    systemd.services.dellfancontroller = {
      description = "Dell PowerEdge Fan Controller";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${dellfancontroller}/bin/dellfancontroller";
        Restart = "always";
        RestartSec = "15s";
        User = "root";
      };
    };
  };
}