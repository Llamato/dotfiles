# Made by Computer_Q (https://github.com/QuintenMuyllaert)
{ config, pkgs, lib, ... }:

let
  # Derivation for kate-wakatime plugin
  kateWakatime = pkgs.stdenv.mkDerivation rec {
    pname = "kate-wakatime";
    version = "unstable-2025-01-01";

    src = pkgs.fetchFromGitHub {
      owner = "Tatsh";
      repo = "kate-wakatime";
      rev = "master";
      hash = "sha256-H3VgL7CpiJphU0G50F8gvpCIa3/S6uP6EjhVcuim5fI=";
    };

    nativeBuildInputs = [ pkgs.cmake pkgs.extra-cmake-modules pkgs.pkg-config ];
    buildInputs = [
      pkgs.qt6.qtbase
      pkgs.kdePackages.ktexteditor
      pkgs.kdePackages.kcoreaddons
      pkgs.kdePackages.kconfig
      pkgs.kdePackages.ki18n
      pkgs.kdePackages.kxmlgui
    ];

    cmakeFlags = [
      "-DCMAKE_INSTALL_PREFIX=$out"
      "-DBUILD_TESTING=OFF"
      "-DCMAKE_PREFIX_PATH=${pkgs.kdePackages.ktexteditor}"
    ];

    dontWrapQtApps = true;
    doCheck = false;

    meta = with lib; {
      description = "WakaTime plugin for Kate";
      homepage = "https://github.com/Tatsh/kate-wakatime";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  # Wrapper derivation for Kate with WakaTime plugin
  wakaKateWrapper = pkgs.stdenv.mkDerivation {
    pname = "waka-kate";
    version = "1.0";

    src = null;

    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildInputs = [ pkgs.kdePackages.kate kateWakatime pkgs.qt6.qtbase ];

    dontWrapQtApps = true;

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/lib/kate-wakatime

      # Copy plugin from kateWakatime
      cp -r ${kateWakatime}/lib/qt6/plugins/kf6/ktexteditor/* $out/lib/kate-wakatime/ || true

      # Copy kate binary to output
      cp ${pkgs.kdePackages.kate}/bin/kate $out/bin/kate.real

      # Create wrapped binary
      makeWrapper $out/bin/kate.real $out/bin/waka-kate \
        --set KATE_PLUGIN_PATH $out/lib/kate-wakatime \
        --set QT_PLUGIN_PATH ${pkgs.qt6.qtbase}/lib/qt6/plugins \
        --set PATH $PATH \
        --prefix LD_LIBRARY_PATH : ${pkgs.qt6.qtbase}/lib
    '';

    # Skip unnecessary phases
    unpackPhase = ":";
    patchPhase = ":";
    configurePhase = ":";
    buildPhase = ":";
    checkPhase = ":";
  };

in {
  # Define the NixOS module options
  options = {
    services.kate-wakatime = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable WakaTime plugin in Kate.";
      };
    };
  };

  # Module configuration
  config = lib.mkIf config.services.kate-wakatime.enable {
    environment.systemPackages =
      [ kateWakatime wakaKateWrapper pkgs.wakatime-cli ];

    # Ensure Kate finds the plugin and Qt plugins
    environment.variables.KATE_PLUGIN_PATH =
      "${kateWakatime}/lib/qt6/plugins/kf6/ktexteditor";
    environment.variables.QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/lib/qt6/plugins";
  };
}
