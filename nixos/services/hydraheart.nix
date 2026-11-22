{ self, ... }: {
  services.hydra = {
    enable = true;
    hydraURL = "http://homelab.llamato.dev:3000";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
    extraConfig = ''
      allow_import_from_derivation = true
    '';
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
          "gccarch-znver5"
          "gccarch-armv7-a"
        ];
        maxJobs = 40;
        protocol = null;
      }
    ];
  };
}
