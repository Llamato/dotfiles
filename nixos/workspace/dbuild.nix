{ config, lib, pkgs, ... }: {
  #Nix remote builders
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.settings.trusted-users = [ "tina" ];
  nix.buildMachines = [ #Make sure to add the host auth key to the known hosts file of root on the client machine. For example by logging in from local root to the sshUser.
    {
      hostName = "10.0.0.1";
      sshUser = "remotebuild";
      sshKey = "/home/tina/.ssh/id_rsa";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm"];
      speedFactor = 1; #Can orbitarily be set. It is advised you agree on a convention for determining the speedFactor.
    }
  ];
}
