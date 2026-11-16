{
  # WireGuard server module, import like:
  #   (import ./nixos/services/wireguard.nix {
  #     peers = [
  #       { name = "wannabethinkpad"; publicKey = "..."; address = "10.10.0.2"; }
  #     ];
  #   })
  #
  # The server private key lives on the host only (root-only file, mode 0600):
  # it is never written to the nix store and never committed.  It is generated
  # with `wg genkey` by an activation script the first time the system is built
  # with this module, and the resulting public key is printed to the activation
  # log so it can be handed to clients.  Seed it by hand to keep an existing
  # key/pubkey pair stable:
  #   install -m 0600 -o root /path/to/privatekey /etc/wireguard/wg0.key
  #
  # Client keys are generated on each machine:  wg genkey | tee privatekey | wg pubkey
  interfaceName ? "wg0",
  port ? 51820,
  address ? "10.10.0.1/24",
  peers ? [ ],
  nat ? true,
  firewallDevice ? "eth0",
  privateKeyFile ? "/etc/wireguard/${interfaceName}.key",
  ...
}:
let
  map = builtins.map;

  peerConfigs = map (
    peer:
    {
      allowedIPs =
        peer.allowedIPs or [
          "${peer.address}/32"
        ];
      publicKey = peer.publicKey;
      persistentKeepalive = peer.persistentKeepalive or 25;
    }
    // (
      if peer ? endpoint then
        {
          endpoint = peer.endpoint;
        }
      else
        { }
    )
  ) peers;
in
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Generate the host private key during activation, i.e. before any unit
  # (systemd-networkd included) is started.  Runs before the interface is
  # configured, which is required because LoadCredential= of a non-existent
  # file makes systemd-networkd fail outright.
  system.activationScripts.setupWireguardHostKey =
    lib.stringAfter
      [
        "users"
        "groups"
        "specialfs"
      ]
      ''
        if [ ! -f ${lib.escapeShellArg privateKeyFile} ]; then
          echo "wireguard: generating new host private key for ${interfaceName}"
          install -d -m 0700 -o root $(dirname ${lib.escapeShellArg privateKeyFile})
          umask 077
          ${pkgs.wireguard-tools}/bin/wg genkey > ${lib.escapeShellArg privateKeyFile}
          chmod 0600 ${lib.escapeShellArg privateKeyFile}
          echo "wireguard: ${interfaceName} host public key: $(${pkgs.wireguard-tools}/bin/wg pubkey < ${lib.escapeShellArg privateKeyFile})"
        fi
      '';

  networking.firewall.allowedUDPPorts = [ port ];

  networking.wireguard.interfaces = {
    ${interfaceName} = {
      ips = [ address ];
      inherit privateKeyFile;
      listenPort = port;
      peers = peerConfigs;
    };
  };

  # Route traffic between the tunnel and the LAN (MASQUERADE).
  networking.nat.enable = nat;
  networking.nat.internalInterfaces = [ interfaceName ];
  networking.nat.externalInterface = firewallDevice;

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
}
