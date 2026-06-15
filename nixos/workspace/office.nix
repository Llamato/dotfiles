{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    sane-airscan
    texlive.combined.scheme-full
    rnote
    simple-scan
    gocr
  ];
}
