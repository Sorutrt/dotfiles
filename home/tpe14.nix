{ config, pkgs, ... }:

let
  niriConfigFile = "${config.home.homeDirectory}/dotfiles/niri/tpe14.kdl";
  waybarConfigFile = "${config.home.homeDirectory}/dotfiles/waybar/config.jsonc";
  waybarCssFile = "${config.home.homeDirectory}/dotfiles/waybar/style.css";
  discordWayland = pkgs.symlinkJoin {
    name = "discord-wayland";
    paths = [ pkgs.unstable.discord ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for command in Discord discord; do
        wrapProgram "$out/bin/$command" \
          --add-flags "--ozone-platform=wayland" \
          --add-flags "--enable-wayland-ime" \
          --add-flags "--wayland-text-input-version=3"
      done
    '';
  };
in
{
  imports = [
    ./desktop.nix
  ];

  home.packages = with pkgs; [
    discordWayland
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
