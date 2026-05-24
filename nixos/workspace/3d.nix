{
  config,
  lib,
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
  ];
}
