{
  inputs,
  pkgs,
  ...
}: let 
  spacepilotDisplay = inputs.spacepilotDisplay.packages.${pkgs.system}.spacepilotDisplay.override {
    jamlytics = true;
  };
in {
  systemd.services.spacepilotJamlyticsDisplay = {
    unitConfig = { 
      Description = "Display the jamlytics logo on connected 3dconnexion spacepilot devices";
      After = [ "multi-user.target" ];
      Wants = [ "multi-user.target" ];
      StartLimitBurst = 3;
      StartLimitIntervalSec = 30;
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${spacepilotDisplay}/bin/spacepilotdisplay ${spacepilotDisplay}/share/jamlytics.packed";
    };
  };
  environment.systemPackages = with pkgs; [
    krita
    blender
    freecad
    audacity
    spacenavd
    spacenav-cube-example
    spacepilotDisplay
  ];
}
