{
  config,
  lib,
  pkgs,
  ...
}:
let
  remotebuildUsers = [ "tina" ]; # Replace with the appropriate users on your client machine
  sshKeyFile = "/home/tina/.ssh/remotebuild"; # The ssh keyfile containing the private key of the remotebuild user on the client system
in
{
  #Nix remote builders
  nix = {
    distributedBuilds = true;
    settings = {
      builders-use-substitutes = true;
      trusted-users = remotebuildUsers;
    };
    buildMachines = [
      # Make sure to add the host auth key to the known hosts file of root on the client machine. For example by logging in from local root to the sshUser.
      {
        hostName = "homelab.llamato.dev";
        sshUser = "remotebuild";
        sshKey = sshKeyFile;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        speedFactor = 1; # Can orbitarily be set. It is advised you agree on a convention for determining the speedFactor.
      }
    ];
  };
}
