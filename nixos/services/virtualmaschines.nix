{ pkgs, ... }:
{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "tina"] ;
  virtualisation.libvirtd = {
  enable = true;
  onBoot = "start";
  qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    swtpm.enable = true;
#    ovmf = {
#      enable = true;
#      packages = [(pkgs.OVMF.override {
#        secureBoot = true;
#        tpmSupport = true;
#        }).fd];
#      };
    };
  };
}
