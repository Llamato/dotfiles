{ lib, stdenv, fetchFromGitHub, autoreconfHook, autoconf-archive, automake, libtool, pkg-config }:

stdenv.mkDerivation rec {
  pname = "psid64";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "hermansr";
    repo = "psid64";
    rev = "v${version}";
    hash = "sha256-cxtKHH25urL3Y5+l2GNCSJZdgRTstaTZfc0W3d8jEqM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    automake
    libtool
    pkg-config
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
    maintainers = with maintainers; [ llamato ];
    platforms = platforms.unix;
  };
}