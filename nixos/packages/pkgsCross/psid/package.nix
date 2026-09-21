{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  autoconf-archive,
  automake,
  libtool,
  pkg-config,
  pkgsBuildBuild,
}:
let
  version = "1.3";
in
stdenv.mkDerivation {
  inherit version;
  pname = "psid64";

  src = fetchFromGitHub {
    owner = "hermansr";
    repo = "psid64";
    rev = "v${version}";
    hash = "sha256-cxtKHH25urL3Y5+l2GNCSJZdgRTstaTZfc0W3d8jEqM=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    automake
    libtool
    pkg-config
    pkgsBuildBuild.binutils
  ];

  # Ensure aclocal finds local macros
  ACLOCAL_PATH = "./macros";

  # Patch to remove -Werror
  prePatch = ''
    sed -i "s/-Werror//g" configure.ac
  '';

  meta = with lib; {
    description = "PSID file converter and native Commodore 64 music player";
    homepage = "https://www.psid64.org/";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    #maintainers = with maintainers; [ llamato ];
  };
}
