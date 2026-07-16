{ lib, pkgs, ... }:

{
  imports = [
    ../workstation.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tpe14-nixos";

  services.power-profiles-daemon.enable = lib.mkForce false;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "powersave";
        energy_performance_preference = "balance_performance";
        platform_profile = "balanced";
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        energy_performance_preference = "power";
        platform_profile = "low-power";
        turbo = "auto";
      };
    };
  };

  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";

  console.useXkbConfig = true;

  fonts = {
    packages = with pkgs; [
      noto-fonts-color-emoji
      plemoljp-nf
    ];
    fontconfig.defaultFonts = {
      monospace = [ "PlemolJP35 Console NF" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  services.xserver.xkb = {
    layout = "us";
    options = "terminate:ctrl_alt_bksp,caps:ctrl_modifier";
  };
}
