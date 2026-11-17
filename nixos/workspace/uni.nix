{pkgs, ... }: {
  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };
  
  environment.systemPackages = with pkgs; [
    eduvpn-client
    pi-coding-agent
    socat
  ];
}