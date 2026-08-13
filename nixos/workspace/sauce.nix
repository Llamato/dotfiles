{inputs, pkgs, ... }: {
  environment.systemPackages = [
    #Tina's flakes
    inputs.gcalc.packages.${pkgs.system}.default
    inputs.gcrypt.packages.${pkgs.system}.default
    inputs.gbounce.packages.${pkgs.system}.default
  ];
}