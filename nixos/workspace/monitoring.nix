{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    vnstat
    iperf3
    mission-center
    ethtool
    inetutils
    net-tools
    mtr
    htop
    (inputs.btop.packages.${system}.btop.override { rocmSupport = true; })
    iotop
    fastfetch
  ];
}
