{ config, inputs, pkgs, ... }:

let
  copyqConfigFile = "${config.home.homeDirectory}/dotfiles/copyq/copyq.conf";
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
    inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop
    mozcTool
    playerctl
    wl-clipboard
    waybar
  ];

  home.file.".config/niri/config.kdl".force = true;
  home.file.".config/copyq/copyq.conf" = {
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink copyqConfigFile;
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
  };

  services.copyq = {
    enable = true;
    forceXWayland = false;
  };
}
