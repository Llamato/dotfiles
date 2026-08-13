{ lib, stdenv, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "psid64";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "hermansr";
    repo = "psid64";
    rev = "v${version}";
    hash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = with lib; {
    description = "PSID file converter and native Commodore 64 music player";
    homepage = "https://www.psid64.org/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ llamato ];
    platforms = platforms.unix;
  };
}