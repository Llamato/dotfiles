{ pkgs, ... }: {
  /*environment.systemPackages = with pkgs; [
    qbittorrent-nox
  ];*/

  systemd.services.qbittorrent-nox = {
    description = "Western Digital MyCloud Home Duo Fan Controller";
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