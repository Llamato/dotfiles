{ pkgs, systems ? [] }: {
  boot.binfmt.emulatedSystems = builtins.filter (system: system != pkgs.stdenv.hostPlatform) systems;
  services.hydra = {
    enable = true;
    hydraURL = "http://homelab.llamato.dev:3000";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ "/etc/nix/machines" ];
    useSubstitutes = true;
  };
  users = {
    groups.hydra = { };
    users.hydra = {
      isSystemUser = true;
      group = "hydra";
    };
  };
  nix = {
    settings.allowed-uris = [
      "github:"
      "git+https://github.com/"
      "git+ssh://github.com/"
    ];
    buildMachines = [
      {
        systems = [ "x86_64-linux" ];
        hostName = "localhost";
        supportedFeatures = [
          "nixos-test"
          "big-parallel"
          "benchmark"
          "kvm"
          "gccarch-armv7-a"
        ];
        maxJobs = 64;
        protocol = null;
      }
    ];
  };
  services.nix-serve = {
    enable = true;
    port = 5000;
    secretKeyFile = "/etc/nix/secret-key";
  };
}
