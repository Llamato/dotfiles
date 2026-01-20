{config, lib, pkgs, ...}: {
  networking.firewall.allowedTCPPorts = [ 8123 ];
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"
      "hisense_aehw4a1"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
    };
    customComponents = with pkgs.home-assistant-custom-components; [
      prometheus_sensor
      
    ];
  };
}