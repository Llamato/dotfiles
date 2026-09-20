{ pkgs, ... }: {
  services.qbittorrent = {
    enable = true;
    package = pkgs.qbittorrent-nox;
    profileDir = "/mnt/raid/torrents";
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        Proxy = {
          Type = 2;
          Host = "localhost";
          Port = 1080;
          OnlyForTorrents = false;
          PeerConnections = true;
        };
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
