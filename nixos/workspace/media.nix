{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    vlc
    cifs-utils nfs-utils
    ffmpeg
    gimp3
    rawtherapee
    exiftool
  ];
}
