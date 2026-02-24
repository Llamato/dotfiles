{
  description = "Tina's NixOS configurations and dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs2205.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    nixpkgs-llamato.url = "github:llamato/nixpkgs/master";
    nixpkgs-hyprgirl.url = "github:hyprgirl/nixpkgs/master";

    nixos-boot.url = "github:Melkor333/nixos-boot";
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
      url = "github:hyprwm/Hyprland?ref=v0.53.1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    /*hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };*/

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
      nixpkgs2205,
      nix-darwin, 
      hyprland, easymotion, split-monitor-workspaces, hyprsplit,
      nixos-boot,
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
          };
          modules = [
            #({config, lib, ...}: {nixpkgs.overlays = [(import ./nixos/overlays/qns-ssh.nix { inherit config lib;})];})
            ./common.nix
            ./nixos/hosts/wannabeonyx.nix
            ./nixos/hosts/wannabeonyx-hw.nix

            ./nixos/modules/hyprland.nix
            #./nixos/modules/kate-wakatime.nix

            ./nixos/services/compatiblessh.nix

            #./nixos/workspace/qssh.nix
            ./nixos/workspace/compatiblessh.nix
            ./nixos/workspace/dev.nix
            ./nixos/workspace/eda.nix
            ./nixos/workspace/3d.nix
            #./nixos/workspace/zvitWg.nix
            #./nixos/workspace/dbuild.nix
            #./nixos/workspace/nordvpn.nix

            #Only needed when not using the overlay
            #./nixos/modules/oqs-openssh.nix
            #./nixos/workspace/qssh.nix

            nixos-boot.nixosModules.default
          ];
        };

        wannabeinthebasement = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./common.nix

            ./nixos/hosts/wannabeinthebasement.nix
            ./nixos/hosts/wannabeinthebasement-hw.nix

            ./nixos/modules/dellfancontrol.nix

            ./nixos/services/nfs.nix
            ./nixos/services/virtualmaschines.nix
          ];
        };

        llamkatttserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./common.nix

          ./nixos/hosts/llamkattthpmicroserver.nix
          ./nixos/hosts/llamkattthpmicroserver-hw.nix

          ./nixos/services/compatiblessh.nix
          ./nixos/services/nfs.nix
          ./nixos/services/virtualmaschines.nix
          ./nixos/services/traefik.nix
          ./nixos/services/bunserver.nix
          ./nixos/services/dbuild.nix
        ];
      };
      
      wannabethinkpad = nixpkgs-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./common.nix

          ./nixos/modules/apple-silicon-support
          
          ./nixos/hosts/wannabethinkpad.nix
          ./nixos/hosts/wannabethinkpad-hw.nix
          ./nixos/modules/hyprland.nix
          ./nixos/workspace/dev.nix          
        ];
      };

      nixnas = nixpkgs2205.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./common.nix

          ./nixos/hosts/nixnas.nix  
          ./nixos/hosts/nixnas-hw.nix

          ./nixos/services/compatiblessh.nix
          ./nixos/services/qbittorrent-nox.nix
        ];
      };
    };

    darwinConfigurations = {
      apowerbooksgrandchild = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs outputs; };
        modules = [
          ./common.nix
          ./darwin/hosts/apowerbooksgrandchild.nix
        ];
      };
    };
  };
}
