{
  inputs,
  pkgs,
  ...
}:
{

  

  environment.systemPackages = with pkgs; [
    krita
    blender
    freecad
    audacity
    spacenavd
    spacenav-cube-example
    inputs.spacepilotDisplay.packages.${pkgs.system}.spacepilotDisplay
  ];
}
