{
  inputs,
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
    thunderbird
    ghostscript
    libreoffice-qt6-fresh

    #Tina's flakes
    inputs.gcalc.packages.${pkgs.system}.default
  ];
}
