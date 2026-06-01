{ inputs, config, pkgs, ... }:

{
  # Enable the Hydra service and its dependencies
  services.hydra = {
    enable = true;
    hydraURL = "http://192.168.3.14:3000";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ ]; # Set empty unless connecting remote builders
    useSubstitutes = true; # Use binary caches instead of building from scratch
    extraConfig = ''
      allow_import_from_derivation = true
    '';
  };
  # Make sure the Hydra user and group are present
  users.users.hydra = {
    isSystemUser = true;
    group = "hydra";
  };
  users.groups.hydra = { };
  nix.settings.allowed-uris = [
  "github:"
  "git+https://github.com/"
  "git+ssh://github.com/"
];
}
