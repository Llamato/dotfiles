{ stdenv, qt6, cmake, fetchFromGitHub, lib }: 
let
  version = "1.0.5";
in
stdenv.mkDerivation {
  inherit version;
  pname = "vchar64";
  src = fetchFromGitHub {
    owner = "ricardoquesada";
    repo = "vchar64";
    rev = "c99c5320aa3d8a704b67ff1470c571e3ac11009d";
    hash = "sha256-+1UlMS63+sQj2/JZ/kT9T6V//Hf8neioJDk8f9HhbPs=";
  };

    strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = with qt6; [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = with qt6; [ 
    qtbase
    qttools
  ];

  cmakeDir = "..";

  meta = with lib; {
    description = "Charset editor for the Commodore 64";
    homepage = "https://github.com/ricardoquesada/vchar64";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ llamato ];
  };
}