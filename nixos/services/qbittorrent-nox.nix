{ pkgs, lib, ... }: let
  semisecrets = (import ../../semisecrets.nix { inherit lib pkgs; }); 
  in {
  services.qbittorrent = {
    enable = false;
    package = pkgs.qbittorrent-nox;
    profileDir = "/mnt/raid/torrents";
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        "Connection\\Proxy\\Type" = "SOCKS5";
        "Connection\\Proxy\\IP" = "192.168.3.11";
        "Connection\\Proxy\\Port" = 1087;
        "Connection\\Proxy\\UseProxyForBT" = true;
        WebUI = {
          Address = "*";
          AuthSubnetWhitelistEnabled=false;
          Username = "tina";
          Password_PBKDF2 = semisecrets.secrets.passwordHashes.qbittorrent;
        };
        General.Locale = "en";
      };
    };
  };
}