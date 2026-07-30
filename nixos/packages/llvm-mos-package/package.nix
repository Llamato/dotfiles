{ lib, symlinkJoin, callPackage, ... }:

let
  llvm-mos = callPackage ../llvm-mos/package.nix {};
  llvm-mos-sdk = callPackage ../llvm-mos-sdk/package.nix {};
in symlinkJoin {
  name = "llvm-mos-package";
  paths = [ 
    llvm-mos 
    llvm-mos-sdk 
  ];
  
  postBuild = ''
    # Wrap the compiler to use sysroot
    for tool in clang clang++; do
      if [ -f "$out/bin/mos-$tool" ]; then
        # Get the real path
        real_path=$(readlink -f "$out/bin/mos-$tool")
        # Remove the symlink
        rm "$out/bin/mos-$tool"
        # Create wrapper script
        cat > "$out/bin/mos-$tool" << EOF
#!/bin/sh
export SDK_ROOT="$out"
exec "$real_path" --sysroot="$out" "\$@"
EOF
        chmod +x "$out/bin/mos-$tool"
      fi
    done
  '';
}