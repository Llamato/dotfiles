{ config, lib, ... }:
{
  config = lib.mkMerge [
    {
      nixpkgs.overlays = [
        (final: prev: {
          oqs-openssh-unwrapped = prev.stdenv.mkDerivation {
            pname = "oqs-openssh-unwrapped";
            version = "OQS-v10";

            src = prev.fetchFromGitHub {
              owner = "open-quantum-safe";
              repo = "openssh";
              rev = "OQS-v10";
              sha256 = "sha256-YXuK6Lg790fkglVgJAWatkivqjqvJUL0bD/UCVhk2VI=";
            };

            nativeBuildInputs = [
              prev.autoreconfHook
              prev.pkg-config
            ];

            buildInputs = [
              prev.zlib
              prev.openssl
              prev.readline
              prev.liboqs
              prev.libedit
              prev.pam
            ];

            configureFlags = [
              "--with-ssl-dir=${prev.openssl.dev}"
              "--with-zlib=${prev.zlib.dev}"
              "--with-liboqs-dir=${prev.liboqs}"
              "--with-libedit"
              "--with-pam"
              "--with-privsep-path=/var/empty"
              "--with-privsep-user=sshd"
              "--enable-alg=default"
              "--enable-kem-alg=all"
              "--enable-sig-alg=all"
            ];

            installTargets = [ "install-files" ];
            installFlags = [
              "sysconfdir=$(out)/etc"
              "STRIP_OPT="
              "PRIVSEP_PATH=$(out)/empty"
            ];

            preInstall = ''
              substituteInPlace Makefile --replace "-m 4711" "-m 0711"
            '';

            postInstall = ''
              mkdir -p $out/bin
              for file in $out/sbin/*; do
                if [ -e "$file" ]; then
                  mv "$file" $out/bin/
                fi
              done
            '';

            meta = with prev.lib; {
              description = "OpenSSH fork with post-quantum crypto (OQS) - unwrapped";
              homepage = "https://github.com/open-quantum-safe/openssh";
              license = licenses.bsd3;
            };
          };

          oqs-openssh = final.symlinkJoin {
            name = "oqs-openssh-${final.oqs-openssh-unwrapped.version}";
            paths = [ final.oqs-openssh-unwrapped ];
            nativeBuildInputs = [ final.makeWrapper ];

            postBuild = ''
              # 1. Retrieve configuration from the system/user config
              pubkeyAlgos="${lib.concatStringsSep "," (config.programs.ssh.pubkeyAcceptedKeyTypes or [ ])}"

              # 2. Remove the symlink created by symlinkJoin so we can replace it
              rm "$out/bin/ssh"

              # 3. Wrap ssh with both PubkeyAcceptedAlgorithms AND HostKeyAlgorithms
              if [ -n "$pubkeyAlgos" ]; then
                makeWrapper "${final.oqs-openssh-unwrapped}/bin/ssh" "$out/bin/ssh" \
                  --add-flags "-o PubkeyAcceptedAlgorithms=$pubkeyAlgos" \
                  --add-flags "-o HostKeyAlgorithms=+$pubkeyAlgos"
              else
                # Fallback: just recreate the symlink if no config is present
                ln -s "${final.oqs-openssh-unwrapped}/bin/ssh" "$out/bin/ssh"
              fi

              # Wrap sftp too
              rm "$out/bin/sftp"
              if [ -n "$pubkeyAlgos" ]; then
                makeWrapper "${final.oqs-openssh-unwrapped}/bin/sftp" "$out/bin/sftp" \
                  --add-flags "-o PubkeyAcceptedAlgorithms=$pubkeyAlgos" \
                  --add-flags "-o HostKeyAlgorithms=+$pubkeyAlgos"
              else
                ln -s "${final.oqs-openssh-unwrapped}/bin/sftp" "$out/bin/sftp"
              fi
            '';

            meta = with prev.lib; {
              description = "OpenSSH fork with post-quantum crypto (OQS)";
              homepage = "https://github.com/open-quantum-safe/openssh";
              license = licenses.bsd3;
            };
          };

          sshfs = prev.stdenv.mkDerivation {
            pname = "oqs-sshfs";
            version = "1.0";

            src = null; # no source

            nativeBuildInputs = [ final.makeWrapper ];
            buildInputs = [
              prev.sshfs
              final.oqs-openssh
            ];

            phases = [ "installPhase" ];

            installPhase = ''
              mkdir -p $out/bin

              # Wrap sshfs to always use oqs-openssh
              makeWrapper ${prev.sshfs}/bin/sshfs $out/bin/sshfs \
                --add-flags "-o ssh_command=${final.oqs-openssh}/bin/ssh"
            '';

            meta = with prev.lib; {
              description = "SSHFS wrapper that uses OQS OpenSSH via -o ssh_command";
              homepage = "https://github.com/open-quantum-safe/openssh";
              license = licenses.bsd3;
            };
          };
        })
      ];
    }
  ];
}
