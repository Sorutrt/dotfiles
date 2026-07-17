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
  wallpaperSelect = pkgs.writeShellApplication {
    name = "wallpaper-select";
    runtimeInputs = with pkgs; [
      awww
      coreutils
      rofi
    ];
    text = ''
      wallpaper_dir="''${XDG_PICTURES_DIR:-"$HOME/Pictures"}/Wallpaper"

      if [[ ! -d "$wallpaper_dir" ]]; then
        printf 'wallpaper directory not found: %s\n' "$wallpaper_dir" >&2
        exit 1
      fi

      selection="$(
        cd "$wallpaper_dir"
        find . -type f \( \
          -iname '*.avif' -o -iname '*.bmp' -o -iname '*.gif' -o \
          -iname '*.jpeg' -o -iname '*.jpg' -o -iname '*.png' -o \
          -iname '*.svg' -o -iname '*.tga' -o -iname '*.tif' -o \
          -iname '*.tiff' -o -iname '*.webp' \
        \) -printf '%P\n' | LC_ALL=C sort | rofi -dmenu -i -p Wallpaper
      )"

      [[ -n "$selection" ]] || exit 0
      awww img --transition-type random --transition-fps 60 "$wallpaper_dir/$selection"
    '';
  };
in
{
  imports = [
    ./common.nix
    ./hermes.nix
  ];

  home.username = "sorutrt";
  home.homeDirectory = "/home/sorutrt";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    foot
    awww
    brightnessctl
    bottom
    inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop
    libnotify
    mozcTool
    wallpaperSelect
    playerctl
    wl-clipboard
    waybar
    kdePackages.dolphin
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
