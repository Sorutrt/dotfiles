{
  inputs = {
    nixpkgs-2605.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    home-manager-2605 = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
  };

  outputs = { self, nixpkgs-2605, nixpkgs-unstable, nixos-wsl, home-manager-2605, ... }@inputs:
  let
    system = "x86_64-linux";

    commonNixosModule = { pkgs, ... }: {
      system.stateVersion = "26.05";

      environment.shells = [ pkgs.nushell ];
      users.defaultUserShell = pkgs.nushell;

      nix = {
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
    };

    mkCommonOverlay = nixpkgs-unstable:
    ({ config, pkgs, ... }:
      {
        nixpkgs.config.allowUnfree = true;

        nixpkgs.overlays = [
          (final: prev: {
            unstable = import nixpkgs-unstable {
              system = prev.system;
              config = prev.config; # allowUnfree などを引き継ぎ
            };
            tokf = final.rustPlatform.buildRustPackage rec {
              pname = "tokf";
              version = "0.2.49";

              src = final.fetchFromGitHub {
                owner = "mpecan";
                repo = "tokf";
                rev = "tokf-v${version}";
                hash = "sha256-3jE2Wo5FyNML/WjfW4EmiOpEAMu58u8xZBje6S3GhfY=";
              };

              cargoHash = "sha256-lPfGtogLld3isO/pPD5KUAFpaZud/KaQf8j6PB9a6Hg=";

              cargoBuildFlags = [ "-p" "tokf" ];
              doCheck = false;
            };
          })
        ];
      }
    );

    mkHomeManagerModule = user: homeModule: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import homeModule;
    };
  in
  {
    nixosConfigurations = {

      # ---------- WSL NixOS ------------------------
      wsl = nixpkgs-2605.lib.nixosSystem {
        inherit system;

        modules = [
          nixos-wsl.nixosModules.default
          ./hosts/wsl/configuration.nix
          commonNixosModule
          (mkCommonOverlay nixpkgs-unstable)

          # home-manager settings
          home-manager-2605.nixosModules.home-manager
          (mkHomeManagerModule "nixos" ./home/wsl.nix)
        ];
      };

      # --------- Macbook Air Mid 2013 -------------------
      mba2013 = nixpkgs-2605.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/mba2013/hardware-configuration.nix
          ./hosts/mba2013/configuration.nix
          commonNixosModule
          (mkCommonOverlay nixpkgs-unstable)

          # home-manager settings
          home-manager-2605.nixosModules.home-manager
          (mkHomeManagerModule "sorutrt" ./home/mba2013.nix)
        ];
      };
      # --------- ThinkPad E14 Gen6 -------------------
      mba2013 = nixpkgs-2605.lib.nixosSystem {
        inherit system;
        modules = [
          # ./hosts/tpe14/hardware-configuration.nix
          ./hosts/tpe14/configuration.nix
          commonNixosModule
          (mkCommonOverlay nixpkgs-unstable)

          # home-manager settings
          home-manager-2605.nixosModules.home-manager
          (mkHomeManagerModule "sorutrt" ./home/tpe14.nix)
        ];
      };

    };
  };
}
