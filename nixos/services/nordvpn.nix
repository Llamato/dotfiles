{config, lib, pkgs, ...}: {
  services.resolved.enable = true;
  systemd.services.wgnord =
  let
    # FIXME: Set your preferred country https://github.com/phirecc/wgnord/blob/master/countries.txt
    country = "United States";
    # FIXME: Set as an absolute path to a file containing your token. It's a
    # secret to be careful with permissions and ownership etc... and do not
    # include the token in your nix config.
    tokenFile = "/mnt/raid/home/tina/dotfiles/nordvpntoken.txt";
    # This template works as is but you can customise it if you want
    template = pkgs.writeText "template.conf" ''
      [Interface]
      PrivateKey = PRIVKEY
      Address = 10.5.0.2/32
      MTU = 1350
      DNS = 103.86.96.100 103.86.99.100

      [Peer]
      PublicKey = SERVER_PUBKEY
      AllowedIPs = 0.0.0.0/0, ::/0
      Endpoint = SERVER_IP:51820
      PersistentKeepalive = 25
    '';
  in
  {
    unitConfig = {
      Description = "Nord Wireguard VPN";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      StartLimitBurst = 3;
      StartLimitIntervalSec = 30;
    };

    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "wgnord";
      StateDirectoryMode = "0700";
      ConfigurationDirectory = "wireguard";
      ConfigurationDirectoryMode = "0700";
      ExecStartPre = [
        "${lib.getExe' pkgs.coreutils "ln"} -fs ${template} /var/lib/wgnord/template.conf"
        "${lib.getExe' pkgs.bash "sh"} -c '${lib.getExe pkgs.wgnord} login \"$(<${tokenFile})\"'"
      ];
      ExecStart = "${lib.getExe pkgs.wgnord} connect \"${country}\"";
      ExecStop = "-${lib.getExe pkgs.wgnord} disconnect";
      Restart = "on-failure";
      RestartSec = 10;
      RemainAfterExit = "yes";
    };
  };
  environment.systemPackages = with pkgs; [
    wgnord
  ];
}