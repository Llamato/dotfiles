{ aurora, ... }: {
  nixpkgs.overlays = [
    aurora.inputs.apple-silicon.overlays.default
    aurora.overlays.default
    (final: prev: {
      libfprint = prev.libfprint.overrideAttrs (old: {
        doInstallCheck = false;
        doCheck = false;
      });
    })
  ];
  #aurora.desktop = "minimal";
  programs.steam.enable = false;
  aurora.fexMesa.enable = false;
}