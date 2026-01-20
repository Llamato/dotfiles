{config, lib, pkgs, ...}: {
services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [
        "tina"
        "quinten"
        "romana"
        "amber"
        "remotebuild"
        "zvit"
        "xlr8"
      ];
      UseDns = true;
      X11Forwarding = false;
      #PermitRootLogin = "yes"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
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
    ];
  };
}
