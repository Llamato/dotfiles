{
  inputs,
  pkgs,
  ...
}:
let
  spacepilotDisplay = inputs.spacepilotDisplay.packages.${pkgs.system}.spacepilotDisplay.override {
    jamlytics = true;
  };
in
{
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c625", TAG+="systemd", ENV{SYSTEMD_WANTS}+="spacepilotJamlyticsDisplay.service"
  '';

  systemd.services.spacepilotJamlyticsDisplay = {
    unitConfig = {
      Description = "Display the jamlytics logo on connected 3dconnexion spacepilot devices";
      StartLimitBurst = 10;
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
