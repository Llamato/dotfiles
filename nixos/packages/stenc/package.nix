{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  pandoc,
}:

stdenv.mkDerivation {
  pname = "stenc";
  version = "2.0.1";
  src = fetchFromGitHub {
    owner = "scsitape";
    repo = "stenc";
    rev = "2.0.1";
    hash = "sha256-M7b+T0mm2QTP1LqqjdKV/NWZ60DrueFEnN1unwCOeH4=";
  };

    strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    autoreconfHook
    pandoc
    pkg-config
  ];

  meta = with lib; {
    description = "SCSI Tape Encryption Manager";
    homepage = "https://github.com/scsitape/stenc";
    license = licenses.gpl2;
    platforms = platforms.unix;
    maintainers = with maintainers; [ llamato ];
  };
}
