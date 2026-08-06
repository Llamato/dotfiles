{ inputs, pkgs, servingDirectory ? "/var/www/public", ... }: {
  systemd.services.bunwebserver = {
    description = "Bun webserver";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = 
       let
        bun-baseline = (pkgs.callPackage ../packages/bun-baseline/package.nix {});
      in
      {
      Type = "simple";
      WorkingDirectory = servingDirectory;
      ExecStart = "${bun-baseline}/bin/bunx serve . -l 6301";
      Restart = "on-failure";
      User = "tina";
    };
  };
}
