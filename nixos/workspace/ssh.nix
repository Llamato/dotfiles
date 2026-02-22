{
  pkgs,
  ...
}:
{

  #Client
  programs.ssh = {
    kexAlgorithms = [
      "curve25519-sha256"
      "curve25519-sha256@libssh.org"
      "diffie-hellman-group-exchange-sha256"
      "diffie-hellman-group14-sha256"
    ];
    pubkeyAcceptedKeyTypes = [
      "ssh-rsa"
      "ssh-ed25519"
    ];
    extraConfig = ''
      ForwardAgent yes
    '';
  };
  environment.systemPackages = with pkgs; [ sshfs ];
}
