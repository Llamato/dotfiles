{ config, lib, ... }: # 1. These are passed by the 'import' in flake.nix
final: prev: {            # 2. These are the standard overlay arguments
  oqs-openssh = prev.stdenv.mkDerivation {
    pname = "oqs-openssh";
    version = "OQS-v10";

    src = prev.fetchFromGitHub {
      owner = "open-quantum-safe";
      repo = "openssh";
      rev = "OQS-v10";
      sha256 = "sha256-kY8GU6t367lXwyQBoPhkrwL5KMpFuH7qB7qxsnQnkR0=";
    };

    nativeBuildInputs = [ 
      prev.autoreconfHook 
      prev.pkg-config 
      prev.makeWrapper 
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

        pubkeyTypes="${
          lib.concatStringsSep ","
          (config.programs.ssh.pubkeyAcceptedKeyTypes or [ ])
        }"

        if [ -n "$pubkeyTypes" ]; then
          wrapProgram $out/bin/ssh \
            --add-flags "-o PubkeyAcceptedKeyTypes=$pubkeyTypes"
        fi
      '';
    meta = with prev.lib; {
      description = "OpenSSH fork with post-quantum crypto (OQS)";
      homepage = "https://github.com/open-quantum-safe/openssh";
      license = licenses.bsd3;
      maintainers = [ ];
    };
  };

  # This replaces the system-wide openssh package with your OQS version
  openssh = final.oqs-openssh;
}