{ config, lib, pkgs, ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "server multi channel support" = "yes";
        "client min protocol" = "SMB3_11";
        "server max protocol" = "SMB3_11";
      };

      "raid" = {
        "path" = "/mnt/raid";
        "browsable" = "yes";
        "read only" = "no";
        "create mask" = "0755";
        "directory mask" = "0775";
        "force user" = "tina";
        "write list" = "tina";
        "writeable" = "yes";
      };
    };
  };
}
