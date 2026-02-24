{config, lib, pkgs, ...}: {
services.openssh = {
    enable = true;
    ports = [ 22 ];
    forwardX11 = true;
    settings = {
      X11Forwarding = true;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [
        "tina"
        "quinten"
        "romana"
        "amber"
        "zvit"
        "xlr8"
        "tyler"
      ];
      UseDns = true;
    };
    hostKeys = [
      {
         openSSHFormat = true;
         path = "/etc/ssh/ssh_host_ed25519_key";
         type = "ed25519";
      }
    ];
  };
}
