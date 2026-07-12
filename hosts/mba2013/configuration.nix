{ config, pkgs, ... }:

{
  imports = [
    ../workstation.nix
  ];

  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "mba2013-nixos";

  console.keyMap = "jp106";

  fonts = {
    packages = with pkgs; [
      plemoljp
    ];
    fontconfig.defaultFonts.monospace = [ "plemoljp" ];
  };

  services.thermald.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.18.34"
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
  ];
  boot.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [
    "b43"
    "bcma"
    "brcmsmac"
    "ssb"
  ];
}
