{
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/raid/ *
      /mnt/raid/home/jamlytics/ *
      /mnt/raid/nixnasroot/ *
    '';
  };
}