{ config, pkgs, ... }:

let
  niriConfigFile = "${config.home.homeDirectory}/dotfiles/niri/tpe14.kdl";
  waybarConfigFile = "${config.home.homeDirectory}/dotfiles/waybar/config.jsonc";
  waybarCssFile = "${config.home.homeDirectory}/dotfiles/waybar/style.css";
  discordCanaryWayland = pkgs.symlinkJoin {
    name = "discord-canary-wayland";
    paths = [ pkgs.unstable.discord-canary ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/DiscordCanary" \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--enable-wayland-ime" \
        --add-flags "--wayland-text-input-version=3"
      ln -s DiscordCanary "$out/bin/discord"
    '';
  };
in
{
  imports = [
    ./desktop.nix
    ./voxtype.nix
  ];
  
  home.packages = with pkgs; [
    discordCanaryWayland
    xwayland-satellite
    obsidian
    onlyoffice-desktopeditors
  ];

  xdg.configFile = {
    "niri/config.kdl" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink niriConfigFile;
    };
    "waybar/config.jsonc" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink waybarConfigFile;
    };
    "waybar/style.css" = {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink waybarCssFile;
    };
  };
}
