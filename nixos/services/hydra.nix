{ ... }: {
  services.hydra = {
    enable = true;
    hydraURL = "http://homelab.llamato.dev:3000";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ ];
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
        hostName = "localhost";
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "armv7l-linux"
          "riscv64-linux"
        ];
        supportedFeatures = [
          "nixos-test"
          "big-parallel"
          "benchmark"
          "gccarch-armv7-a"
        ];
        maxJobs = 64;
      }
    ];
  };
  services.nix-serve = {
    enable = true;
    port = 5000;
    secretKeyFile = "/etc/nix/secret-key";
  };
}
