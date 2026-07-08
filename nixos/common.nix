{ ... }: {
programs.git = {
    enable = true;
    lfs.enable = true;
    prompt.enable = true;
    lfs.enablePureSSHTransfer = true;
  };
}