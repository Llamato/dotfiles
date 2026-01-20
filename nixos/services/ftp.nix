{ config, lib, pkgs, ... }:
{
  services.vsftpd = {
    enable = true;
    chrootlocalUser = true;
    allowWriteableChroot = true;
    writeEnable = true;
    localUsers = true;
    userlist = [ "tina" "kattt" ];
    userlistEnable = true;
    userlistDeny = false;
    extraConfig = ''
        ftpd_banner=Welcome to the LlamKattt server
        pasv_enable=Yes
        pasv_addr_resolve=YES
        pasv_min_port=49152
        pasv_max_port=49407
        pasv_address=80.129.131.204
        log_ftp_protocol=YES
        vsftpd_log_file=/mnt/raid/logs/vsftpd.log
        syslog_enable=YES
        dual_log_enable=YES
        xferlog_enable=YES
        xferlog_file=/mnt/raid/logs/xferlog.log
        xferlog_std_format=YES
      '';
  };
}
