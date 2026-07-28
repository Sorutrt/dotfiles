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
    voxtype
    wtype
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
    "voxtype/config.toml".text = ''
      engine = "whisper"
      state_file = "auto"

      [hotkey]
      enabled = false
      mode = "toggle"

      [audio]
      device = "default"
      sample_rate = 16000
      max_duration_secs = 60

      [whisper]
      model = "small"
      language = "ja"
      translate = false
      on_demand_loading = false

      [output]
      mode = "type"
      fallback_to_clipboard = true
      type_delay_ms = 0

      [output.notification]
      on_recording_start = true
      on_recording_stop = true
      on_transcription = true
    '';
  };

  systemd.user.services.voxtype = {
    Unit = {
      Description = "VoxType push-to-talk voice-to-text daemon";
      After = [ "graphical-session.target" "pipewire.service" "pipewire-pulse.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.voxtype}/bin/voxtype -q daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
