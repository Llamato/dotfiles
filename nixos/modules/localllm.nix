{ pkgs, ... }:
{
  hardware.graphics.enable = true;
  environment.systemPackages = with pkgs; [
    vulkan-tools
    lmstudio
  ];

  # Strata needs RLIMIT_MEMLOCK for its PLE n-gram table (28.8 GB for IQ3_S)
  # and its pinned expert arena (46.8 GB). With the 8 MiB kernel default the
  # engine prints "PLE table mlock failed (Cannot allocate memory; raise
  # `ulimit -l`)" and the table is left reclaimable. See docs/AMD_HIP.md.
  # PAM limits apply to login sessions only, not to systemd services -
  # llama-cpp.service below is unaffected.
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
}