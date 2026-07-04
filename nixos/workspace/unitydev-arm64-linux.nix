{ pkgs, ... }:

let
  pkgs-x86_64 = import pkgs.path {
    system = "x86_64-linux";
    config.allowUnsupportedSystem = true;
    config.allowUnfree = true;
  };
in
{
  # 1. Force the kernel to allow unprivileged user namespaces (Fixes bwrap)
  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1;
    "user.max_user_namespaces" = 10000; # Ensure enough namespace slots are open
  };

  # 2. Add an explicit SUID wrapper for bubblewrap if the kernel blocks it over QEMU
  security.wrappers.bwrap = {
    setuid = true;
    owner = "root";
    group = "root";
    source = "${pkgs.bubblewrap}/bin/bwrap";
  };

  # Your existing emulated systems architecture config
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  # Keep your nix-ld configurations from the previous step here
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs-x86_64; [
      glibc glib zlib nss nspr alsa-lib atk at-spi2-atk at-spi2-core
      cairo pango gdk-pixbuf gtk3 libsecret libuuid cups dbus expat mesa libGL
      xorg.libX11 xorg.libXext xorg.libXcursor xorg.libXrandr xorg.libXi
      xorg.libXcomposite xorg.libXdamage xorg.libXfixes xorg.libXrender
      xorg.libXtst xorg.libXScrnSaver
    ];
  };

  environment.systemPackages = [
    pkgs-x86_64.unityhub
  ];
}