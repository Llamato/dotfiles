{
  lib,
  clangStdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  libimobiledevice,
  libusb1,
  avahi,
  clang,
  git,
  libgeneral,
}:
clangStdenv.mkDerivation {
  pname = "usbmuxd2";
  version = "unstable-2026-10-01";

  src = fetchFromGitHub {
    owner = "tihmstar";
    repo = "usbmuxd2";
    rev = "master";
    hash = "sha256-tNKNceZHMAWwhngt3n4XXbY1w6CeWhYbvWHBuODEvV4";
    # Leave DotGit so that autoconfigure can read version from git tags
    leaveDotGit = true;
  };

  postPatch = ''
    # Checking for libgeneral version still fails
    sed -i 's/libgeneral >= $LIBGENERAL_MINVERS_STR/libgeneral/' configure.ac

    # Otherwise, it will complain about no matching function for call to 'find'
    sed -i 1i'#include <algorithm>' usbmuxd2/Muxer.cpp
  '';

  nativeBuildInputs = [
    autoreconfHook
    clang
    git
    pkg-config
  ];

  propagatedBuildInputs = [
    avahi
    libgeneral
    libimobiledevice
    libusb1
  ];

  doInstallCheck = true;

  configureFlags = [
    "--with-udevrulesdir=${placeholder "out"}/lib/udev/rules.d"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
  ];

  makeFlags = [
    "sbindir=${placeholder "out"}/bin"
  ];

  meta = {
    homepage = "https://github.com/tihmstar/usbmuxd2";
    description = "Socket daemon to multiplex connections from and to iOS devices";
    license = lib.licenses.lgpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ onny ];
    mainProgram = "usbmuxd";
  };
}