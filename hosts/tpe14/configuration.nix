{ pkgs, ... }:

{
  imports = [
    ../workstation.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tpe14-nixos";

  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";

  console.useXkbConfig = true;

  fonts = {
    packages = with pkgs; [
      noto-fonts-color-emoji
      plemoljp-nf
    ];
    fontconfig.defaultFonts = {
      monospace = [ "PlemolJP Console NF" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  services.xserver.xkb = {
    layout = "us";
    options = "terminate:ctrl_alt_bksp,caps:ctrl_modifier";
  };
}
