{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    qbittorrent-nox
  ];

  systemd.services.qbittorrent-nox = {
    description = "qbittorrent-nox client with webui";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "15s";
      User = "tina";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
    };
  };
}