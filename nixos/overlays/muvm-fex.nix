{ pkgs, inputs, ... }: {
  # Applying the overlay globally
  nixpkgs.overlays = [ inputs.nixos-mmuvm-fex.overlays.default ];
  environment.systemPackages = [ pkgs.muvm ];

  # Applying the overlay only for muvm
  #environment.systemPackages = [ (pkgs.extend inputs.nixos-mmuvm-fex.overlays.default).muvm ];
}

