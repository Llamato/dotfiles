{ lib, pkgs, ... }:
let
  fetchKeysFromGithub =
    with builtins // lib;
    username: splitString "\n" (readFile (fetchurl "https://github.com/${username}.keys"));
  makeUserEntry =
    username: trust:
    {
      ssh ? [ ],
      gpg ? [ ],
    }:
    {
      ${username} = {
        inherit trust;
        keys = {
          ssh = ssh;
          gpg = gpg;
        };
      };
    };
in
{
  userTrustThreshold = 1000;
  rootTrustThreshold = 9001;
  semisecrets =
    makeUserEntry "tina" 9002 { ssh = fetchKeysFromGithub "llamato"; }
    // makeUserEntry "quinten" 2000 { ssh = fetchKeysFromGithub "QuintenMuyllaert"; }
    // makeUserEntry "amber" 2000 { ssh = fetchKeysFromGithub "ShyAssassin"; }
    // makeUserEntry "romana" 2000 { ssh = fetchKeysFromGithub "HyprGirl"; }
    // makeUserEntry "xlr8" 2000 { ssh = fetchKeysFromGithub "0x48piraj"; }
    // makeUserEntry "zvit" 2000 {
      ssh = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLTCoAAHoImrR+FdiWmGJDD7ke8MmiTaZukANS/uPvQ"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEePG3qRnXD2QqpWLM80nBls+9T9kX5U3IKJn3UdTSe"
      ];
    };
}
