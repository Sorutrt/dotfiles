{ config, pkgs, ... }:

let
  niriConfigFile = "${config.home.homeDirectory}/dotfiles/niri/config.kdl";
in
{
  imports = [
    ./desktop.nix
  ];

  home.packages = with pkgs; [
    discord
  ];

  home.file.".config/niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink niriConfigFile;
}
