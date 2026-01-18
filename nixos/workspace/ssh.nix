{ config, pkgs, inputs, lib, ... }: {
  #Quantum
  imports = [../modules/oqs-openssh.nix ];

  #Server
  services.openssh = {
    package = pkgs.oqs-openssh;
    enable = true;
    ports = [ 3001 ];
    extraConfig = ''
      PubkeyAcceptedAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256,ssh-falcon512,ssh-falcon1024
    '';

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      PermitRootLogin = "no";
      KexAlgorithms = null;
      AllowUsers = [ "tina" "romana" ];
    };
  };

  #Client
  programs.ssh = {
    package = pkgs.oqs-openssh;
    kexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" "diffie-hellman-group-exchange-sha256" "diffie-hellman-group14-sha256" ];
    pubkeyAcceptedKeyTypes = [ "ssh-rsa" "ssh-ed25519" "ssh-falcon512" "ssh-falcon1024" ];
    #extraConfig = "#Extra config";
  };
  environment.systemPackages = with pkgs;[ sshfs];
}