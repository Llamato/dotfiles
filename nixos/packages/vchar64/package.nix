{ stdenv, qt6, cmake, fetchFromGitHub, lib }: 
let
  version = "1.0.4";
in
stdenv.mkDerivation {
  inherit version;
  pname = "vchar64";
  src = fetchFromGitHub {
    owner = "ricardoquesada";
    repo = "vchar64";
    tag = ''v${version}'';
    hash = "sha256-ucv6PdFrOOJjIshXcqDfphg6V27poei0Sh0O5OvjqQ4=";
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