{
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt  0.0.0.0(rw,fsid=0,no_subtree_check)
    '';
  };
}