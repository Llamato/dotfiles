{ config, pkgs, inputs, lib, ... }: {
systemd.services.telnet-debug = {
    description = "Emergency Telnet Server (No Auth)";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart =
        "${pkgs.busybox}/bin/telnetd -F -p 23 -l ${pkgs.busybox}/bin/bash";
      Restart = "always";
    };
  };
}