{pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    eduvpn-client
  ];
}