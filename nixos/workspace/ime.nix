{ pkgs, ... }:
let
  ibus-engines = [
    "mozc"
  ];
in
{
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus = {
      waylandFrontend = true;
      engines = map (engineName: pkgs.ibus-engines.${engineName}) ibus-engines;
    };
  };
  environment.sessionVariables = {
    GTK_IM_MODULE = "wayland,ibus,xim";
    QT_IM_MODULE = "wayland,ibus";
    XMODIFIERS = "@im=ibus";
    SDL_IM_MODULE = "wayland,ibus";
    INPUT_METHOD = "ibus";
  };
}