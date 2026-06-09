{
  inputs = {
    nixpkgs-2511.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-2605.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };

    home-manager-2511 = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-2511";
    };
    home-manager-2605 = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
  };

  outputs = { self, nixpkgs-2511, nixpkgs-2605, nixpkgs-unstable, nixos-wsl, home-manager-2511, home-manager-2605, ... }@inputs: 
  let
    system = "x86_64-linux";

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
          })
        ];
      }
    );
  in
  {
    nixosConfigurations = {

      # ---------- WSL NixOS ------------------------
      wsl = nixpkgs-2605.lib.nixosSystem {
        inherit system;

        modules = [
          nixos-wsl.nixosModules.default
          ./hosts/wsl/configuration.nix
          (mkCommonOverlay nixpkgs-unstable)

          # home-manager settings
          home-manager-2605.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nixos = import ./home/wsl.nix;
          }
          {
            system.stateVersion = "26.05";
          }
        ];
      };

      # --------- Macbook Air Mid 2013 -------------------
      mba2013 = nixpkgs-2511.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/mba2013/configuration.nix
          (mkCommonOverlay nixpkgs-unstable)

          # home-manager settings
          home-manager-2511.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sorutrt = import ./home/mba2013.nix;
          }
          {
            system.stateVersion = "25.11";
          }
        ];
      };
    }; 
  };
}
