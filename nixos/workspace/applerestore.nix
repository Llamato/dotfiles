{ pkgs, gpkgs, ... }: {
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  environment.systemPackages = [
    pkgs.idevicerestore
    pkgs.libimobiledevice
    pkgs.libirecovery
    pkgs.libplist
    pkgs.libtatsu
  ];
} 