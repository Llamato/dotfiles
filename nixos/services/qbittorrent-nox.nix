{ pkgs, ... }: {
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
          Password_PBKDF2="@ByteArray(6a5uZbO9yKW5/ScWabltvw==:xVSh8UHwV0TgnBs1t0aYnARXbVBD8zmGYLpMnFgdChIOmLURFzY8TEh1aBkjUh3P7bl17q0QmyNp5esW5RLMXw==)";
        };
        General.Locale = "en";
      };
    }
    ;
  };
}