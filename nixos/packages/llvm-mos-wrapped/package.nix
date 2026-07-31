{ lib, symlinkJoin, callPackage, runCommand, ... }:

let
  llvm-mos = callPackage ../llvm-mos/package.nix {};
  sdk = callPackage ../llvm-mos-sdk/package.nix {};
  combined = symlinkJoin {
    name = "llvm-mos-toolchain";
    paths = [ llvm-mos sdk ];
    
    postBuild = ''
      # Patch .cfg files to use absolute paths
      for cfg in $out/bin/*.cfg; do
        if [ -f "$cfg" ]; then
          # Replace <CFGDIR>/.. with the actual SDK root
          sed -i "s|<CFGDIR>/\.\.|$out|g" "$cfg"
        fi
      done
    '';
  };
in runCommand "llvm-mos-wrapped" {} ''
  mkdir -p $out
  cp -r ${combined}/* $out/
  chmod -R u+w $out
  
  # Create the symlink chain
  cd $out/bin
  
  # Ensure clang-23 is present (or symlink to it)
  if [ ! -f "clang-23" ] && [ -f "${llvm-mos}/bin/clang-23" ]; then
    ln -sf ${llvm-mos}/bin/clang-23 clang-23
  fi
  
  # Create mos-clang -> clang -> clang-23 chain
  ln -sf clang mos-clang 2>/dev/null || true
  ln -sf clang mos-clang++ 2>/dev/null || true
  ln -sf clang mos-clang-cpp 2>/dev/null || true
  
  # Create platform-specific symlinks
  for cfg in *.cfg; do
    if [ -f "$cfg" ]; then
      base=$(basename "$cfg" .cfg)
      ln -sf mos-clang "$base-clang" 2>/dev/null || true
      ln -sf mos-clang "$base-clang++" 2>/dev/null || true
      ln -sf mos-clang "$base-clang-cpp" 2>/dev/null || true
    fi
  done
''