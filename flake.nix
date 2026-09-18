{
  description = "Tina's NixOS configurations and dotfiles";

  inputs = {
    #nixos package repos
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    nixpkgs2205.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs2511.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-llamato.url = "github:llamato/nixpkgs/master";

    #nix darwin package repos
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-26.05";

    #nixos on apple silicon
    apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    nixos-muvm-fex.url = "github:nrabulinski/nixos-muvm-fex";

    #specialty hardware support
    stenc.url = "github:llamato/stenc";
    openlogi = {
      url = "github:AprilNEA/OpenLogi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #hyprland and it's addons
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

    #External config
    secrets.url = "/etc/nixos/secrets";

    #software made by Tina
    gcalc.url = "github:llamato/gcalc";
    gcrypt.url = "github:llamato/gcrypt";
    gbounce.url = "github:llamato/glossyBallBounce";
    cbmtext.url = "github:llamato/cbmText";

    #software made by friends
    kurogane.url = "github:0x48piraj/kurogane/master";
    devnotify = {
      url = "github:ShyAssassin/devnotify";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rom-a-dotfiles = {
      url = "github:HyprGirl/dotfiles";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs2205,
      nix-darwin,
      apple-silicon,
      openlogi,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "armv7l-linux"
        "riscv64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          lib = pkgs.lib;
          packagesPath = ./nixos/packages;
        in
        lib.filterAttrs (pname: pdrv: builtins.elem system pdrv.meta.platforms) (
          builtins.listToAttrs (
            map
              (packageName: {
                name = packageName;
                value = pkgs.callPackage "${packagesPath}/${packageName}/package.nix" { };
              })
              (
                builtins.attrNames (
                  lib.filterAttrs (name: value: value == "directory") (builtins.readDir packagesPath)
                )
              )
          )
        )
      );

      lib = {
        foldl1 =
          op: list:
          if list == [ ] then
            throw "foldl1: empty list"
          else
            builtins.foldl' op (builtins.head list) (builtins.tail list);

        normalizeLicense =
          license:
          if builtins.isList license then
            if builtins.length license > 1 then
              self.lib.foldl1 (
                acc: first: second:
                nixpkgs.lib.licenses.AND first second
              )
            else
              builtins.head license
          else
            license;
      };

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
            
            openlogi.nixosModules.default
            ./nixos/modules/river.nix

            ./nixos/services/commenssh.nix

            ./nixos/workspace/hyprland.nix
            ./nixos/workspace/dev.nix
            ./nixos/workspace/eda.nix
            ./nixos/workspace/3d.nix
            ./nixos/workspace/benchmark.nix
            ./nixos/workspace/office.nix
            ./nixos/workspace/media.nix
            ./nixos/workspace/monitoring.nix
            ./nixos/workspace/sauce.nix
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
            ./nixos/services/hydra.nix
            ./nixos/services/storageserver.nix
            (import ./nixos/services/smb.nix {
              shares = [
                "osraid"
                "stripe"
              ];
            })
          ];
        };

        llamkatttserver = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./common.nix

            ./nixos/modules/jamlytics.nix

            ./nixos/hosts/llamkattthpmicroserver.nix
            ./nixos/hosts/llamkattthpmicroserver-hw.nix

            (import ./nixos/services/smb.nix { shares = [ "raid" ]; })
            (import ./nixos/services/bunserver.nix {
              pkgs = nixpkgs.legacyPackages.${system};
              servingDirectory = "/mnt/raid/www/public";
            })

            ./nixos/services/nfs.nix
            ./nixos/services/virtualmaschines.nix
            ./nixos/services/traefik.nix
            ./nixos/services/devserver.nix
            ./nixos/services/storageserver.nix
          ];
        };

        /*
          wannabethinkpad = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = { inherit inputs outputs; };
            modules = [
              ./common.nix

              apple-silicon.nixosModules.apple-silicon-support
              ./nixos/hosts/wannabethinkpad.nix
              ./nixos/hosts/wannabethinkpad-hw.nix

              ./nixos/workspace/dev.nix
              ./nixos/workspace/3d.nix
              ./nixos/workspace/office.nix
              ./nixos/workspace/communications.nix
              ./nixos/workspace/monitoring.nix
              ./nixos/workspace/sauce.nix
            ];
          };
        */

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
            ./nixos/workspace/communications.nix
            ./nixos/workspace/office.nix
            ./nixos/workspace/monitoring.nix
            ./nixos/workspace/sauce.nix
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
            ./nixos/workspace/media.nix
            ./nixos/workspace/monitoring.nix
            ./nixos/workspace/sauce.nix
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
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./nixos/modules/jamlytics.nix

            ./nixos/hosts/bpim1.nix
            ./nixos/hosts/bpim1-hw.nix
          ];
        };
      };

      darwinConfigurations = {
        apowerbooksgrandchild = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./common.nix

            ./darwin/hosts/apowerbooksgrandchild.nix
          ];
        };
      };

      hydraJobs = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            # Evaluate unfree packages
            config.allowUnfree = true;
          };
          lib = pkgs.lib;
        in
        # Do not include unfree packages in hydra jobs
        lib.filterAttrs (
          pname: package: lib.licenses.isFree (self.lib.normalizeLicense package.meta.license)
        ) self.packages.${system}
      );
    };
}
