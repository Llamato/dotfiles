{
stdenvNoCC,
lib,
fetchzip
}: let
  platformMap = {
    "x86_64-linux" = "linux-x86_64";
    "i686-linux" = "linux-i386";
    "x86_64-darwin" = "maxosx-x86_64";
    "i686-darwin" = "maxosx-i386";
    "aarch64-darwin" = "maxosx-x86_64";
    "x86_64-freebsd" = "freebsd-x86_64";
    "i686-freebsd" = "freebsd-i386";
    "x86_64-solaris" = "solaris-x64-64";
    "i686-solaris" = "solaris-i386";
    "x86_64-windows" = "windows-i386";
    "i686-windows" = "windows-i386";
  };
  currentSystem = builtins.currentSystem or "x86_64-linux";
  platformSrc = platformMap.${currentSystem} or (throw "Unsupported system: ${currentSystem}");
in stdenvNoCC.mkDerivation {
  pname = "tmpx";
  version = "1.1";
  src = fetchzip {
        url = "https://style64.org/file/TMPx_v1.1.0-STYLE.zip";
        sha256 = "sha256-Qini9kRLosuF88wEqoCyR1u+LN6RtQIrRjGCSIpxtVk=";
      };

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/tmpx
    cp -R ${platformSrc}/tmpx $out/bin
    chmod +x $out/bin/tmpx
    cp -R ${platformSrc}/readme.txt $out/share/tmpx
  '';
  
  meta = with lib; {
    description = "LLVM-MOS SDK for 6502-based systems";
    homepage = "https://llvm-mos.org";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.llamato ];
  };
}