{
  pkgs,
  lib,
  config,
  ...
}:

let
  ipmitool = pkgs.ipmitool;

  dellfancontroller = pkgs.writeShellScriptBin "dellfancontroller" (lib.readFile ../../scripts/wannabeinthebasement/dellfancontroller.sh);
in
{
  options.services.dellfancontroller = {
    enable = lib.mkEnableOption "Dell PowerEdge fan controller";
  };

  config = lib.mkIf (config.services.dellfancontroller or { }).enable {
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
