{ config, pkgs, ... }:

let
  hyprlandConfigFile = "${config.home.homeDirectory}/dotfiles/hypr/hyprland.lua";
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
    discord
    mozcTool
    playerctl
    wl-clipboard
  ];

  home.file.".config/hypr/hyprland.lua" = {
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink hyprlandConfigFile;
  };
}
