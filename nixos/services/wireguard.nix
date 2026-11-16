{
  # WireGuard server module, import like:
  #   (import ./nixos/services/wireguard.nix {
  #     peers = [
  #       { name = "wannabethinkpad"; publicKey = "..."; address = "10.10.0.2"; }
  #     ];
  #   })
  #
  # Generate keys on each machine:  wg genkey | tee privatekey | wg pubkey
  # The server's private key is managed via sops (secrets.yaml key: wg-privatekey)
  # or generated at runtime with wg genkey if privateKeyFile does not exist.
  interfaceName ? "wg0",
  port ? 51820,
  address ? "10.10.0.1/24",
  peers ? [ ],
  nat ? true,
  firewallDevice ? "eth0",
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
  # Server private key, kept out of the nix store via sops.
  # Add to secrets/secrets.yaml:  wg-privatekey: <output of `wg genkey`>
  sops.secrets.wg-privatekey = {
    owner = "root";
    mode = "0600";
  };

  networking.firewall.allowedUDPPorts = [ port ];

  networking.wireguard.interfaces = {
    ${interfaceName} = {
      ips = [ address ];
      privateKeyFile = config.sops.secrets.wg-privatekey.path;
      listenPort = port;
      peers = peerConfigs;
    };
  };

  # Route traffic between the tunnel and the LAN (MASQUERADE).
  networking.nat.enable = nat;
  networking.nat.internalInterfaces = [ interfaceName ];
  networking.nat.externalInterface = firewallDevice;
}
