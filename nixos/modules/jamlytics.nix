{ pkgs, lib, homedir ? "/home", ... } : let
  semisecrets = (import ../../semisecrets.nix { inherit lib pkgs; });
  makeUser = username: { ${username} = {
    isNormalUser = true;
    initialPassword = "6301";
    extraGroups = [ "jamlytics" "users" "dailout" ];
    home = "${homedir}/${username}";
    createHome = true;
    openssh.authorizedKeys.keys = semisecrets.semisecrets.${username}.keys.ssh;
  };
};
in {
  users.users = makeUser "tina"
  // makeUser "quinten"
  // makeUser "amber"
  // makeUser "romana"
  // makeUser "xlr8"
  // makeUser "zvit";
}