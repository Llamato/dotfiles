{pkgs, bun ? pkgs.bun, servingDirectory ? "/var/www/public", ... }: {
  systemd.services.bunwebserver = {
    description = "Bun webserver";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = 
       let
      in
      {
      Type = "simple";
      WorkingDirectory = servingDirectory;
      ExecStart = "${bun}/bin/bunx serve . -l 6301";
      Restart = "on-failure";
      User = "tina";
    };
  };
}
