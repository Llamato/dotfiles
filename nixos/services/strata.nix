# The Strata server as a systemd service. Not imported by nixos/hosts/wannabeonyx.nix today - the
# server is started from a shell with run-iq3_xxs-huge-7900xtx.sh there.
#
# To use it: import this file in the host config and set `services.strata.enable = true;`
# (nixos/hosts/wannabeonyx.nix has that line commented out). A systemd unit does not inherit the PAM
# login limits, so its own LimitMEMLOCK is set below.
#
# Two things this model needs, and where they now live:
#   - the 2 MiB huge-page pool (the IQ3_XXS expert arena asks for 20464 pages, IQ3_S for 23983):
#     reserved at boot by boot.kernelParams in nixos/hosts/wannabeonyx.nix ("hugepages=32768").
#     A unit that writes nr_hugepages itself would shrink that reserve, so none is done here.
#   - RLIMIT_MEMLOCK for the 26.8 GiB PLE table (measured up to 6% faster decode, engine #4671):
#     security.pam.loginLimits in nixos/hosts/wannabeonyx.nix for shell runs, LimitMEMLOCK below for
#     this unit. The engine can raise its own soft limit but never the hard one.
{
  pkgs,
  ...
}:
let
  strata_xxs = "/home/tina/git/Strata-Tina-7900xtx/run-iq3_xxs-huge-7900xtx.sh";
in
{
  boot.kernelParams = [ "iommu=pt" ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 200;
    "kernel.numa_balancing" = 0;
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

  systemd.services.strata = {
    description = "Strata server (Qwen3.8-Flash-Next IQ3_XXS, RX 7900 XTX / gfx1100)";
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      User = "tina";
      Group = "users";
      WorkingDirectory = "/home/tina/git/Strata-Tina-7900xtx";

      # Page-lock limit for the n-gram (PLE) table, 26.8 GiB on this model.
      LimitMEMLOCK = "infinity";

      # If you cap this unit, cap it with MemoryMax only. MemoryHigh counts the page cache the
      # expert arena reads from and suspends the GPU queues while it reclaims (Strata
      # docs/AMD_HIP.md, "Linux: verify timeouts while the kernel reclaims host memory").
      # MemoryMax = ...;

      # The "+" prefix runs these two as root even though the unit runs as tina, so a unit needs no
      # sudoers rule (the shell route in the run script does: see security.sudo.extraRules in
      # nixos/hosts/wannabeonyx.nix). Same 24576 pages the run script takes.
      ExecStartPre = "+" + pkgs.writeShellScript "strata-take-hugepages" ''
        sync
        echo 3 > /proc/sys/vm/drop_caches
        echo 1 > /proc/sys/vm/compact_memory
        echo 24576 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
        got=$(cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages)
        echo "strata: 2 MiB pool set to $got of 24576 pages ($(( got * 2 / 1024 )) GiB)"
      '';

      # Give the RAM back when the server stops, unless another engine is still serving.
      ExecStopPost = "+" + pkgs.writeShellScript "strata-free-hugepages" ''
        if ! pgrep -f "strata --serve" >/dev/null 2>&1; then
          echo 0 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
        fi
      '';

      ExecStart = strata_xxs;
    };
  };
}
