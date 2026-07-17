{ config, inputs, pkgs, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dotfilesDir = "${config.home.homeDirectory}/dotfiles/";
  footConfigFile = "${dotfilesDir}/foot/foot.ini";
  copyqConfigFile = "${dotfilesDir}/copyq/copyq.conf";
  makoConfigFile = "${dotfilesDir}/mako/config";
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
    foot
    brightnessctl
    bottom
    inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop
    libnotify
    mozcTool
    playerctl
    wl-clipboard
    waybar
  ];

  xdg.configFile = {
    "foot/foot.ini".source = mkOutOfStoreSymlink footConfigFile;
    "copyq/copyq.conf" = {
      force = true;
      source = mkOutOfStoreSymlink copyqConfigFile;
    };
    "mako/config" = {
      source = mkOutOfStoreSymlink makoConfigFile;
      onChange = "${pkgs.mako}/bin/makoctl reload || true";
    };
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
  };

  services.copyq = {
    enable = true;
    forceXWayland = false;
  };

  services.mako.enable = true;

  systemd.user.services.copyq.Service.Environment = [
    "QT_QPA_PLATFORM=wayland"
  ];
}
