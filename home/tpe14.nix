{ config, pkgs, ... }:

let
  niriConfigFile = "${config.home.homeDirectory}/dotfiles/niri/tpe14.kdl";
  waybarConfigFile = "${config.home.homeDirectory}/dotfiles/waybar/config.jsonc";
  waybarCssFile = "${config.home.homeDirectory}/dotfiles/waybar/style.css";
in
{
  imports = [
    ./desktop.nix
  ];

  home.packages = with pkgs; [
    unstable.discord
    xwayland-satellite
    obsidian
    onlyoffice-desktopeditors
  ];

  home.file.".config/niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink niriConfigFile;

  home.file.".config/waybar/config.jsonc" = {
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink waybarConfigFile;
  };
  home.file.".config/waybar/style.css" = {
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink waybarCssFile;
  };

}
