{
  stdenv,
  lib,
  fetchFromGitHub,
  gcc,
  gnumake,
  gtk3,
  gtk3-x11,
  cairo,
  pkg-config
}:
stdenv.mkDerivation {
  pname = "tek4010";
  version = "1.9.0";
  src = fetchFromGitHub {
    owner = "Llamato";
    repo = "Tek4010";
    rev = "master";
    hash = "sha256-5wUEIdiZSbC2yq0pCU2lVdwaa+QEADIZOqEGYa7mH4c=";
  };

  nativeBuildInputs = [ 
    gcc
    gnumake
  ];

  buildInputs = [
    gtk3
    gtk3-x11
    cairo.dev
    pkg-config
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp tek4010 $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tek4010 - Tektronics 4010 emulator";
    license = licenses.gpl3;
    maintainers = with maintainers; [ llamato ];
    platforms = platforms.unix;
  };
}