{ pkgs, ... }:

{
  home.packages = with pkgs; [
    voxtype
    wtype
  ];

  xdg.configFile."voxtype/config.toml".text = ''
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
    model = "base"
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

    [osd]
    enabled = false
  '';

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
