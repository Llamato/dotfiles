{ inputs, pkgs, ... }: {
  systemd.services.bunwebserver = {
    description = "Bun webserver";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/mnt/raid/www/public";
      ExecStart = "${inputs.nixpkgs-llamato.legacyPackages.${pkgs.system}.bun-baseline}/bin/bunx serve . -l 6301";
      Restart = "on-failure";
      User = "tina";
    };
  };
}
