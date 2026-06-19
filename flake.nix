{
  description = "Tina's NixOS configurations and dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    nixpkgs2205.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-llamato.url = "github:llamato/nixpkgs/master";
    nixpkgs-hyprgirl.url = "github:hyprgirl/nixpkgs/master";

    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";

    apple-silicon.url = "github:nix-community/nixos-apple-silicon?ref=release-25.11";

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

    devnotify = {
      url = "github:ShyAssassin/devnotify";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs2205,
      nixpkgs-llamato,
      nix-darwin, 
      nixos-boot,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      #nixosModules = import ./nixos/modules/default.nix;
      #overlays = import ./nixos/overlays/overlays.nix {inherit inputs outputs;};

      nixosConfigurations = {
        wannabeonyx = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./common.nix
  
            ./nixos/hosts/wannabeonyx.nix
            ./nixos/hosts/wannabeonyx-hw.nix

            ./nixos/modules/river.nix
            ./nixos/modules/kate-wakatime.nix 
            ./nixos/modules/lto.nix

            ./nixos/services/commenssh.nix

            ./nixos/workspace/hyprland.nix
            ./nixos/workspace/dev.nix
            ./nixos/workspace/eda.nix
            ./nixos/workspace/3d.nix
            ./nixos/workspace/benchmark.nix
            ./nixos/workspace/office.nix
            
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

            (import ./nixos/services/smb.nix {shares = [ "osraid" "stripe" ];})
            
            ./nixos/services/nfs.nix
            ./nixos/services/virtualmaschines.nix
            ./nixos/services/hydra.nix
          ];
        };

        llamkatttserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./common.nix

          ./nixos/modules/jamlytics.nix

          ./nixos/hosts/llamkattthpmicroserver.nix
          ./nixos/hosts/llamkattthpmicroserver-hw.nix
          
          (import ./nixos/services/smb.nix {shares = [ "raid" ];})

          ./nixos/services/nfs.nix
          ./nixos/services/virtualmaschines.nix
          ./nixos/services/traefik.nix
          ./nixos/services/bunserver.nix
          ./nixos/services/devserver.nix
        ];
      };
      
      wannabethinkpad = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./common.nix

          ./nixos/modules/apple-silicon-support
          ./nixos/modules/jamlytics.nix
          
          ./nixos/hosts/wannabethinkpad.nix
          ./nixos/hosts/wannabethinkpad-hw.nix

          ./nixos/services/devserver.nix   
        ];
      };

      wannabewannabethinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./common.nix

          ./nixos/hosts/wannabethinkpad.nix
          ./nixos/hosts/wannabewannabethinkpad-hw.nix

          ./nixos/workspace/hyprland.nix
          ./nixos/workspace/dev.nix
        ];
      };

      actuallythinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./common.nix
          
          ./nixos/hosts/actuallythinkpad.nix
          ./nixos/hosts/actuallythinkpad-hw.nix

          ./nixos/workspace/dev.nix
        ];
      };

      idonotevenknowwhatiwantthistobe = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./common.nix

          ./nixos/hosts/actuallythinkpad.nix
          ./nixos/hosts/idonotevenknowwhatiwantthistobe-hw.nix

          ./nixos/workspace/dev.nix
        ];
      };

      wannabethinkpadsmother = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [ 
          ./common.nix

          ./nixos/hosts/actuallythinkpad.nix
          ./nixos/hosts/wannabethinkpadsmother-hw.nix

          ./nixos/workspace/dev.nix
        ];
      };

      wannaberiscv = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./common.nix

          ./nixos/hosts/wannaberiscv.nix
          ./nixos/hosts/wannaberiscv-hw.nix

          ./nixos/workspace/dev.nix
          ./nixos/workspace/3d.nix
          ./nixos/workspace/office.nix
        ];
      };

      nixnasduo = nixpkgs2205.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./common.nix

          ./nixos/modules/jamlytics.nix
          ./nixos/modules/nixnas.nix

          ./nixos/hosts/nixnasduo.nix  
          ./nixos/hosts/nixnas-hw.nix

          ./nixos/services/qbittorrent-nox.nix
        ];
      };

      bpim1 = nixpkgs.lib.nixosSystem {
        system = "armv7l-linux";
        specialArgs = {inherit inputs outputs; };
        modules = [
          #./common.nix

          ./nixos/modules/jamlytics.nix

          ./nixos/hosts/bpim1.nix
          ./nixos/hosts/bpim1-hw.nix
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
    hydraJobs = let
      nixosBuilds = builtins.mapAttrs (_: config: config.config.system.build.toplevel) (builtins.filter (config: config.system == "x86_64-linux")) self.nixosConfigurations; 
    in nixosBuilds;
  };
}
