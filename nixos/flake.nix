{
  inputs = {
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-2511.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs-2505";
    };

    home-manager-2505 = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-2505";
    };
    home-manager-2511 = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-2511";
    };

  };

  outputs = { self, nixpkgs-2505, nixpkgs-2511, nixpkgs-unstable, nixos-wsl, home-manager-2505, home-manager-2511, ... }@inputs: 
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
      nixos-wsl = nixpkgs-2505.lib.nixosSystem {
        inherit system;

        modules = [
          nixos-wsl.nixosModules.default
          ./hosts/wsl-nixos/configuration.nix
          (mkCommonOverlay nixpkgs-unstable)

          # home-manager settings
          home-manager-2505.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nixos = import ./home/wsl-nixos.nix;
          }
          {
            system.stateVersion = "25.05";
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
