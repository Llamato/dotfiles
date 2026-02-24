{
  pkgs,
  ...
}:
{

  # --- Networking ---
  networking.hostName = "NixNas";
  
  # Enable DHCP on all interfaces to be safe
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.firewall.enable = false; # DISABLE FIREWALL FOR DEBUGGING
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ]; # Fallback DNS

  # --- Entropy Fix (Fixes SSH hang) ---
  services.haveged.enable = true;

  # --- SSH Access (Headless) ---
  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
    forwardX11 = true;
  };

  # --- X11 forwarding ---
  services.xserver.enable = true;

  users.users = {
    root.password = "root"; 
    tina = {
      isNormalUser = true;
      description = "Tina";
      password = "llamato";
      extraGroups = [
        "networkmanager"
        "wheel"
        "scanner"
        "lp"
        "docker"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmuHyyOtAxG1GSuqIoeeGfV8XfLQGzS6zalYuAumlD+ tina_modern"
        #"ssh-falcon1024 AAAADnNzaC1mYWxjb24xMDI0AAAHAQqaziOEHQMfjzzldpYUP3+mYzpujWGR8IvWrIJtdHyjFHdt61Q9UGj3QAdLcjQGXk1xcW0l6+2kHi1IZXh/y35BTixUj+sdsehlqGOnhWFkPepJonQkRm>
        #"ssh-falcon512 AAAADXNzaC1mYWxjb241MTIAAAOBCYselVfYAiMNMr/352O5W05OFNCDgR/VQOKtihMduSTDbZFYUxXU+b8Kh3IBg9A3aw0FcMp6PayAiu5oV5WL0zdoivJP1pGakIKUdFhdFCH9xtfIiJGQP9b>
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    busybox
    git
    htop
    btop
    iproute2
    iperf
    neofetch
    sl
    cowsay
    fortune
    nfs-utils
    qbittorrent-nox
    xorg.xauth

    # GOD HELP
    (pkgs.writeShellScriptBin "nixos-rebuild" ''
      #!/bin/sh
      # Run the packaged nixos-rebuild from nixpkgs
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild "$@"
    '')
  ];

    # 1. Telnet: Bypass login prompt (login program might be failing)
    systemd.services.telnet-debug = {
      description = "Emergency Telnet Server (No Auth)";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart =
          "${pkgs.busybox}/bin/telnetd -F -p 23 -l ${pkgs.busybox}/bin/sh";
        Restart = "always";
      };
    };

    # 2. Raw Bind Shell: Port 9999 (Netcat)
    # "poor man's reverse shell" - connect with `nc <IP> 9999`
    systemd.services.bindshell-debug = {
      description = "Emergency Bind Shell";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart =
          "${pkgs.busybox}/bin/nc -ll -p 9999 -e ${pkgs.busybox}/bin/sh";
        Restart = "always";
      };
    };

    # 3. HTTP Server (Port 8080)
    systemd.services.http-debug = {
      description = "Emergency HTTP Server";
      wantedBy = [ "multi-user.target" ];
      script = ''
        mkdir -p /tmp/www
        echo "<h1>Hello from NixOS MyCloud $PATH</h1>" > /tmp/www/index.html
        ${pkgs.busybox}/bin/httpd -f -p 8081 -h /tmp/www
      '';
    };

    # 4. FTP Server (Port 21)
    systemd.services.ftp-debug = {
      description = "Emergency FTP Server";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        # -w: Write access, -S: Log to syslog, -t 600: Idle timeout
        ExecStart =
          "${pkgs.busybox}/bin/tcpsvd -vE 0.0.0.0 21 ${pkgs.busybox}/bin/ftpd -w -S /";
        Restart = "always";
      };
    };

  # --- State Version ---
  system.stateVersion = "22.05";
}
