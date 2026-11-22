{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (cutter.withPlugins (ps: with ps; [ rz-ghidra jsdec ]))
  ];
}