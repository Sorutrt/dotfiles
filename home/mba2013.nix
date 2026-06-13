{ config, pkgs, ... }:

let
  hyprlandConfigFile = "${config.home.homeDirectory}/dotfiles/hypr/hyprland.lua";

in
{
  imports = [
    ./common.nix
  ];

  home.username = "sorutrt";
  home.homeDirectory = "/home/sorutrt";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    brightnessctl
    playerctl
  ];

  home.file.".config/hypr/hyprland.lua" = {
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink hyprlandConfigFile;
  };
}
