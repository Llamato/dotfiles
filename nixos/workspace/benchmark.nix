{
  config,
  lib,
  pkgs,
  ...
}: {
   environment.systemPackages = with pkgs; [
    stress-ng
    geekbench
   ];
}