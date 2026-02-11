{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    kicad
    simavr
    arduino
    avra
    avrdude
    pkgs.pkgsCross.avr.buildPackages.gcc
  ];
}
