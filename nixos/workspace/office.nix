{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    sane-airscan
    rnote
    simple-scan
    gocr
    thunderbird
    ghostscript
    libreoffice-qt6-fresh
    joplin-desktop
    #Tina's flakes
    inputs.gcalc.packages.${pkgs.system}.default
  ];
}
