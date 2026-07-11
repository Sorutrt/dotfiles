{ config, pkgs, ... }:

let
  niriConfigFile = "${config.home.homeDirectory}/dotfiles/niri/tpe14.kdl";
  mozcTool = pkgs.writeShellScriptBin "mozc_tool" ''
    exec ${pkgs.mozc}/lib/mozc/mozc_tool "$@"
  '';

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
    bottom
    discord
    mozcTool
    playerctl
    wl-clipboard
    waybar
  ];

  home.file.".config/niri/config.kdl" = {
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink niriConfigFile;
  };
}
