{ pkgs, ... }: {
  services.qbittorrent = {
    package = pkgs.qbittorrent-nox;
    openFirewall = true;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          Username = "tina";
          Password = "6301";
        };
        General.Locale = "en";
      };
    }
    ;
  };
}
