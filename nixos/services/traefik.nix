{ config, lib, pkgs, ... }:
{
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":443";
          asDefault = true;
          http.tls.certResolver = "letsencrypt";
        };
      };

      log = {
        level = "INFO";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "tguessbacher@gmx.de";
        storage = "${config.services.traefik.dataDir}/acme.json";
        httpChallenge.entryPoint = "web";
      };

      api.dashboard = true;
      # Access the Traefik dashboard on <Traefik IP>:8080 of your server
      api.insecure = true;
    };

    dynamicConfigOptions = {
      http.routers = {
        router1 = {
          rule = "Host(`homelab.llamato.dev`) || Host(`10.0.0.1`)";
          service = "service1";
        };
      };
      http.services = {
         service1 = {
          loadBalancer = {
            servers = [
              {
                url = "http://127.0.0.1:6301";
              }
            ];
          };
        };
      };
    };
  };
}