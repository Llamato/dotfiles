{
  rustPlatform,
  fetchFromGitHub,
}:
let
  pname = "serial-tether";
  version = "0.11.0";
in
rustPlatform.buildRustPackage {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "hulryung";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-rSZxVZmZ7riuMgRd9Iwpei3cwQfe17bXoeGTzX4mjH8";
  };
  cargoHash = "sha256-g2rjbPrGLFFbn+K0SvTquwAXvTarOW2RVqyE7yLzk9E=";
  doCheck = false;
}
