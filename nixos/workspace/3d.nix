{config, lib, pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    krita
    blender
    freecad
    audacity
  ];
}