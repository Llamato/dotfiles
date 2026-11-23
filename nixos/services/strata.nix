{pkgs, ...}: let 
  rocmRoot = pkgs.symlinkJoin {
    name = "rocm-root";
    paths = with pkgs.rocmPackages; [
      rocm-smi
      clr
      hipcc
      rocm-device-libs
      rocminfo
      rocm-runtime
      clang
      rocm-core
      rocm-comgr
      hipblas
      hipblas-common
      hipblaslt
      rocblas
      rocsolver
    ];
  };
in {
  environment.systemPackages = [
    rocmRoot
  ];
}