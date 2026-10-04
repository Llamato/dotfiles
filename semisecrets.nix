{ lib, ... }:
let
  fetchKeysFromGithub =
    with builtins // lib;
    username: splitString "\n" (readFile (fetchurl "https://github.com/${username}.keys"));
  makeUserEntry =
    username:
    {
      ssh ? [ ],
      gpg ? [ ],
    }:
    {
      ${username} = {
        keys = {
          ssh = ssh;
          gpg = gpg;
        };
      };
    };
in
{
  semisecrets =
    makeUserEntry "tina" {
      ssh = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmuHyyOtAxG1GSuqIoeeGfV8XfLQGzS6zalYuAumlD+ tina_modern"
      ];
    }
    // makeUserEntry "quinten" { ssh = fetchKeysFromGithub "QuintenMuyllaert"; }
    // makeUserEntry "amber" { ssh = fetchKeysFromGithub "ShyAssassin"; }
    // makeUserEntry "romana" { ssh = fetchKeysFromGithub "R0M-A"; }
    // makeUserEntry "xlr8" { ssh = fetchKeysFromGithub "0x48piraj"; }
    // makeUserEntry "zvit" {
      ssh = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLTCoAAHoImrR+FdiWmGJDD7ke8MmiTaZukANS/uPvQ"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEePG3qRnXD2QqpWLM80nBls+9T9kX5U3IKJn3UdTSe"
      ];
    };

  secrets = {
    passwordHashes = {
      qbittorrent = "@ByteArray(6a5uZbO9yKW5/ScWabltvw==:xVSh8UHwV0TgnBs1t0aYnARXbVBD8zmGYLpMnFgdChIOmLURFzY8TEh1aBkjUh3P7bl17q0QmyNp5esW5RLMXw==)";
    };
  };
}
