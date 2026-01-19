{
  description = "Tina's NixOS configurations and dotfiles";

  inputs = {
    #nixpkgs2511.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    nixpkgs-llamato.url = "github:llamato/nixpkgs/master";
    nixpkgs-hyprgirl.url = "github:hyprgirl/nixpkgs/master";
    gcalc = {
      url = "github:llamato/gcalc";
    };

    gcrypt = {
      url = "github:llamato/gcrypt";
    };

    gbounce = {
      url = "github:llamato/glossyBallBounce";
    };

    stenc = {
      url = "github:llamato/stenc";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    easymotion = {
      url = "github:zakk4223/hyprland-easymotion";
      inputs.hyprland.follows = "hyprland";
    };

    hyprsplit = {
      url = "github:shezdy/hyprsplit";
      inputs.hyprland.follows = "hyprland";
    };

    split-monitor-workspaces = {
      inputs.hyprland.follows = "hyprland";
      url = "github:Duckonaut/split-monitor-workspaces";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      easymotion,
      hyprland,
      split-monitor-workspaces,
      hyprsplit,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "armv7l-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      #nixosModules = import ./nixos/modules/default.nix;
      #overlays = import ./nixos/overlays/overlays.nix {inherit inputs outputs;};
      #packages = forAllSystems (system: import ./nixos/packages nixpkgs.legacyPackages.${system});

      nixosConfigurations = {
        wannabeonyx = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs;
            /*
              overlays = [
                (import ./nixos/overlays/qns-ssh.nix {})
              ];
            */
          };
          modules = [
            #({config, lib, ...}: {nixpkgs.overlays = [(import ./nixos/overlays/qns-ssh.nix { inherit config lib;})];})
            ./common.nix
            ./nixos/hosts/wannabeonyx.nix
            ./nixos/hosts/wannabeonyx-hw.nix

            ./nixos/modules/hyprland.nix
            #./nixos/modules/kate-wakatime.nix

            ./nixos/workspace/ssh.nix
            ./nixos/workspace/dev.nix
            ./nixos/workspace/eda.nix
            ./nixos/workspace/3d.nix
            #./nixos/workspace/zvitWg.nix
            #./nixos/workspace/dbuild.nix
            #./nixos/workspace/nordvpn.nix

            #Only needed when not using the overlay
            #./nixos/modules/oqs-openssh.nix
            #./nixos/workspace/qssh.nix
          ];
        };
        wannabeinthebasement = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./nixos/hosts/wannabeinthebasement.nix
            ./nixos/hosts/wannabeinthebasement-hw.nix
          ];
        };
      };
    };
}
