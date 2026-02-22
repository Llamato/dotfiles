{
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/raid  *
    '';
  };
}