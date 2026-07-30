{ lib, buildEnv, callPackage, makeWrapper, ... }:

let
  llvm-mos = callPackage ../llvm-mos/package.nix {};
  llvm-mos-sdk = callPackage ../llvm-mos-sdk/package.nix {};
in buildEnv {
  name = "llvm-mos-wrapped";
  paths = [ 
    llvm-mos 
    llvm-mos-sdk 
  ];
  
  postBuild = ''
    # Now wrap the compilers (files are writable in buildEnv)
    for tool in clang clang++ clang-cpp; do
      if [ -f "$out/bin/mos-$tool" ] && [ ! -L "$out/bin/mos-$tool" ]; then
        # Move original
        mv "$out/bin/mos-$tool" "$out/bin/mos-$tool.real"
        # Create wrapper
        cat > "$out/bin/mos-$tool" << EOF
#!/bin/sh
exec "$out/bin/mos-$tool.real" -I"$out/mos-platform/common/include" "\$@"
EOF
        chmod +x "$out/bin/mos-$tool"
      fi
    done
  '';
}