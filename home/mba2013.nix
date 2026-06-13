{ config, ... }:

let
  hyprlandConfigFile = "../hypr/hyprland.lua";
in
{
  imports = [
    ./common.nix
  ];

  home.username = "sorutrt";
  home.homeDirectory = "/home/sorutrt";
  home.stateVersion = "26.05";

  home.file.".config/hypr/hyprland.lua" = {
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink hyprlandConfigFile;
  };

  home.packages = [

  ];
}
