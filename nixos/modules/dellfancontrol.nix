{pkgs, ...} : rec {
   dellfancontroller = pkgs.stdenv.mkDerivation {
    pname = "dellfancontroller";
    version = "unstable-2025-01-19";

    src = "./scripts/wannabeinthebasement/.";
   };
  systemd.services.dellfancontroller = {
  enable = true;
  serviceConfig = {
     ExecStart = "${dellfancontroller}/governtemp.sh";
   };
};
}