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
}