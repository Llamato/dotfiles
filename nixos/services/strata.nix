{ config, pkgs, ... }: let
  strata_xxs = "/home/tina/git/Strata-Tina/run-iq3_xxs-huge.sh";
  strata_s = "/home/tina/git/Strata-Tina/run-iq3_s.sh";
 in {
  boot = { 
    kernelParams = [
    "default_hugepagesz=2M"
    "hugepagesz=2M"
    "hugepages=0"
    "hugepagesz=1G"
    "hugepages=0"
    "iommu=pt"
  ];
  
  kernel.sysctl = {
    #"vm.nr_hugepages" = 32768;
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 200;
    "kernel.numa_balancing" = 0;
  };
  };

  fileSystems."/dev/hugepages" = {
    device = "hugetlbfs";
    fsType = "hugetlbfs";
    options = [ "pagesize=2M" "mode=1770" "gid=kvm" ];
  };

  fileSystems."/dev/hugepages1G" = {
    device = "hugetlbfs";
    fsType = "hugetlbfs";
    options = [ "pagesize=1G" "mode=1770" "gid=kvm" ];
  };

  hardware.graphics.enable = true;
  environment.systemPackages = with pkgs; [
    vulkan-tools
    lmstudio
  ];
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "unlimited"; # or "infinity" depending on the item
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "soft";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "hard";
      item = "memlock";
      value = "unlimited";
    }
  ];

  systemd.services.strata = {
    description = "Strata Service with Dynamic 2M & 1G HugePages";
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      User = "tina";
      Group = "users";
      WorkingDirectory = "/home/tina/git/Strata-Tina";

      ExecStartPre = "+" + pkgs.writeShellScript "strata-alloc-hugepages" ''
        echo 3 > /proc/sys/vm/drop_caches
        echo 1 > /proc/sys/vm/compact_memory
        echo 4096 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
        echo 4 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
      '';

      ExecStart = strata_xxs;

      ExecStopPost = "+" + pkgs.writeShellScript "strata-free-hugepages" ''
        echo 0 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
        echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
      '';
    };
  };
}
