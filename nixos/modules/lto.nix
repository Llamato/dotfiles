{ pkgs, inputs, ... }: {
  environment.systemPackages = with pkgs; [
    inputs.stenc.packages.${pkgs.system}.stenc
    bash
    mt-st
    sg3_utils
    _7zz
    ripgrep
  ];
}