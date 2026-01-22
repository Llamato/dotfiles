{
  pkgs,
  ...
}:
{
  #Quantum
  imports = [ ../modules/oqs-openssh.nix ];

  #Client
  programs.ssh = {
    package = pkgs.oqs-openssh;
    kexAlgorithms = [
      "mlkem768x25519-sha256"
      "sntrup761x25519-sha512"
      "curve25519-sha256"
      "curve25519-sha256@libssh.org"
      "diffie-hellman-group-exchange-sha256"
      "diffie-hellman-group14-sha256"
    ];
    pubkeyAcceptedKeyTypes = [
      "ssh-rsa"
      "ssh-ed25519"
      "ssh-falcon512"
      "ssh-falcon1024"
    ];
    #extraConfig = "#Extra config";
  };
  environment.systemPackages = with pkgs; [ sshfs ];
}
