{ config, lib, pkgs, modulesPath, ... }:                                                                                     
                                                                                                                             
{                                                                                                                            
  imports =                                                                                                                  
    [ (modulesPath + "/installer/scan/not-detected.nix")                                                                     
    ];                                                                                                                       

  boot.loader.systemd-boot.enable = true;                                                                                                                                                                                                                      
  boot.loader.efi.canTouchEfiVariables = true;                                                                                                               
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];                                  
  boot.initrd.kernelModules = [ ];                                                                                           
  boot.kernelModules = [ "kvm-amd" ];                                                                                        
  boot.extraModulePackages = [ ];                                                                                            
                                                                                                                             
  fileSystems."/" =                                                                                                          
    { device = "/dev/disk/by-uuid/16a23950-dff4-48ac-8fac-08d552b478c4";                                                     
      fsType = "ext4";                                                                                                       
    };                                                                                                                       
                                                                                                                             
  fileSystems."/boot" =                                                                                                      
    { device = "/dev/disk/by-uuid/D58A-B053";                                                                                
      fsType = "vfat";                                                                                                       
      options = [ "fmask=0077" "dmask=0077" ];                                                                               
    };                                                                                                                       
                                                                                                                             
  swapDevices =                                                                                                              
    [ { device = "/dev/disk/by-uuid/af574293-856c-4943-9b85-17e2c567d0a9"; }                                                 
    ];                                                                                                                       
                                                                                                                             
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";                                                                       
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;                            
}                                                          