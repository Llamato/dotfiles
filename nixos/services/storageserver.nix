{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    jdupes
    ncdu
    iperf 
    vnstat
    smartmontools#
    ripgrep
  ];
}