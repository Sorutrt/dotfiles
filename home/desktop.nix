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
  logisimEvolution = pkgs.symlinkJoin {
    name = "logisim-evolution-wayland";
    paths = [ pkgs.logisim-evolution ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/logisim-evolution
      makeWrapper ${pkgs.logisim-evolution}/bin/logisim-evolution $out/bin/logisim-evolution \
        --set _JAVA_AWT_WM_NONREPARENTING 1
    '';
  };
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
  gtklockLock = pkgs.writeShellApplication {
    name = "gtklock-lock";
    runtimeInputs = with pkgs; [
      awww
      coreutils
      gawk
      gtklock
      imagemagick
    ];
    text = ''
      cache_dir="''${XDG_CACHE_HOME:-"$HOME/.cache"}/gtklock"
      background="$cache_dir/background.png"
      wallpaper="$(awww query | awk -F 'currently displaying: image: ' '/currently displaying: image:/ { print $2; exit }')"

      if [[ -z "$wallpaper" || ! -f "$wallpaper" ]]; then
        printf 'could not determine the current awww wallpaper\n' >&2
        exit 1
      fi

      mkdir -p "$cache_dir"
      dimensions="$(identify -format '%wx%h' "$wallpaper")"
      magick "$wallpaper" -resize 50% -blur 0x12 -resize "$dimensions!" \
        -fill '#2b3339' -colorize 18 "$background"
      exec gtklock --background="$background"
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
    imagemagick
    libnotify
    mozcTool
    wallpaperSelect
    gtklockLock
    playerctl
    wl-clipboard
    waybar
    kdePackages.dolphin
    logisimEvolution
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
    "gtklock/config.ini".source = mkOutOfStoreSymlink "${dotfilesDir}/gtklock/config.ini";
    "gtklock/layout.ui".source = mkOutOfStoreSymlink "${dotfilesDir}/gtklock/layout.ui";
    "gtklock/style.css".source = mkOutOfStoreSymlink "${dotfilesDir}/gtklock/style.css";
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    gtk3.extraConfig.gtk-enable-primary-paste = false;
    gtk4.extraConfig.gtk-enable-primary-paste = false;
  };

  services.copyq = {
    enable = true;
    forceXWayland = false;
  };

  services.mako.enable = true;

  systemd.user.services.copyq.Service = {
    Environment = [
      "QT_QPA_PLATFORM=wayland"
    ];
    ExecStartPost = [
      "${pkgs.copyq}/bin/copyq eval \"while (size()) remove(0)\""
    ];
  };
}
