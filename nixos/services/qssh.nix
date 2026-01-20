{ config, pkgs, inputs, lib, ... }: {
  services.openssh = {
    package = pkgs.openssh;
    enable = true;
    services.openssh.allowSFTP = true;
    ports = [ 22 ];
    extraConfig = ''
          PubkeyAcceptedKeyTypes ssh-falcon512,ssh-falcon1024
          PubkeyAcceptedAlgorithms ssh-falcon512,ssh-falcon1024
          HostkeyAlgorithms ssh-falcon512,ssh-falcon1024
      '';
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
      KexAlgorithms = null; #Is this insrecure? Plaintext?
      AllowUsers = [
        "tina"
        "romana"
        "quinten"
        "amber"
        "zvit"
      ];
    };
   hostKeys = [
      /*{
        bits = 4096;
        openSSHFormat = true;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }*/
      /*{
         openSSHFormat = true;
         path = "/etc/ssh/ssh_host_ed25519_key";
         type = "ed25519";
      }*/
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
  
  programs.ssh.pubkeyAcceptedKeyTypes = [
    "ssh-falcon512"
    "ssh-falcon1024"
    #"ssh-ed25519"
    #"ssh-rsa"
  ];
}
