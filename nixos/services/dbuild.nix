{ config, lib, pkgs, ... }: {
  /*users.users.${buildername} = {
    isSystemUser = true;
    createHome = false;
    uid = 500;
    group = buildername;
    useDefaultShell = true;
    openssh.authorizedKeys.keyFiles = [ "/mnt/raid/home/tina/.ssh/${buildername}.pub" ];
  };
  users.groups.${buildername} = {
		gid = 500;
	};
  nix.settings.trusted-users = [ buildername ];
  services.openssh.enable = lib.mkForce true;*/

  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" "riscv64-linux" ];
  nix.settings = {
    substitute = true;
    trusted-users = [ "remotebuild" ];
  };

  users.users.remotebuild = {
    isSystemUser = true;
    group = "remotebuild";
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmuHyyOtAxG1GSuqIoeeGfV8XfLQGzS6zalYuAumlD+ tina_modern" 
    ];
  };
  users.groups.remotebuild = {};
}