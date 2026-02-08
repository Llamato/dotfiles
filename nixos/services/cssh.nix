{ pkgs, ... }: {

  #Quantum
  imports = [ ../modules/oqs-openssh.nix ];

  services.openssh = {
    package = pkgs.oqs-openssh;
    enable = true;
    allowSFTP = true;
    ports = [ 22 ];
    extraConfig = ''
          PubkeyAcceptedKeyTypes ssh-falcon512,ssh-falcon1024,ssh-ed25519
          PubkeyAcceptedAlgorithms ssh-falcon512,ssh-falcon1024,ssh-ed25519
          HostkeyAlgorithms ssh-falcon512,ssh-falcon1024,ssh-ed25519
      '';
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
      KexAlgorithms = [
        "mlkem768x25519-sha256"
        #"sntrup761x25519-sha512"
        "curve25519-sha256"
        "diffie-hellman-group-exchange-sha256"
        "diffie-hellman-group14-sha256"
      ];
      AllowUsers = [
        "tina"
        "romana"
        "quinten"
        "amber"
        "zvit"
        "xlr8"
        "tyler"
      ];
    };
   hostKeys = [
      {
        bits = 4096;
        openSSHFormat = true;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
         openSSHFormat = true;
         path = "/etc/ssh/ssh_host_ed25519_key";
         type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_falcon512_key";
        type = "falcon512";
      }
      {
        path = "/etc/ssh/ssh_host_falcon1024_key";
        type = "falcon1024";
      }
    ];
  };
}
