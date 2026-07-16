{
  inputs = {
    nixpkgs-2605.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
    firefox-nightly.url = "github:nix-community/flake-firefox-nightly";
    tokf = {
      url = "github:mpecan/tokf";
      flake = false;
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    home-manager-2605 = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
  };

  outputs = { self, nixpkgs-2605, nixpkgs-unstable, nixos-wsl, home-manager-2605, tokf, ... }@inputs:
  let
    system = "x86_64-linux";

    commonNixosModule = { pkgs, ... }: {
      system.stateVersion = "26.05";

      environment.shells = [ pkgs.nushell ];
      users.defaultUserShell = pkgs.nushell;

      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
    };

    commonOverlayModule = import ./overlays { inherit nixpkgs-unstable tokf; };

    mkHomeManagerModule = user: homeModule: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
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
          commonOverlayModule

          # home-manager settings
          home-manager-2605.nixosModules.home-manager
          (mkHomeManagerModule "nixos" ./home/wsl.nix)
        ];
      };

      # --------- Macbook Air Mid 2013 -------------------
      mba2013 = nixpkgs-2605.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/mba2013/hardware-configuration.nix
          ./hosts/mba2013/configuration.nix
          commonNixosModule
          commonOverlayModule

          # home-manager settings
          home-manager-2605.nixosModules.home-manager
          (mkHomeManagerModule "sorutrt" ./home/mba2013.nix)
        ];
      };
      # --------- ThinkPad E14 Gen6 -------------------
      tpe14 = nixpkgs-2605.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/tpe14/hardware-configuration.nix
          ./hosts/tpe14/configuration.nix
          commonNixosModule
          commonOverlayModule

          # home-manager settings
          home-manager-2605.nixosModules.home-manager
          (mkHomeManagerModule "sorutrt" ./home/tpe14.nix)
        ];
      };

    };
  };
}
