{ inputs, pkgs, ... }:

let
  voxtypePackage = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.onnx;
in
{
  home.packages = [
    voxtypePackage
    pkgs.wtype
  ];

  xdg.configFile."voxtype/config.toml".text = ''
    engine = "sensevoice"
    state_file = "auto"

    [hotkey]
    enabled = false
    mode = "toggle"

    [audio]
    device = "default"
    sample_rate = 16000
    max_duration_secs = 60

    [sensevoice]
    model = "sensevoice-small"
    language = "ja"
    use_itn = true
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
      ExecStart = "${voxtypePackage}/bin/voxtype -q daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
