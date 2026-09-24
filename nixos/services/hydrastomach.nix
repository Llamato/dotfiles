  { self, ... }: {
  services.nix-serve = {
    enable = true;
    port = 5000;
    secretKeyFile = "/etc/nix/secret-key";
  };
}