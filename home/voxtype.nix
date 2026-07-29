{ inputs, pkgs, ... }:

let
  voxtypeUnwrapped = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.voxtype-onnx-unwrapped.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./voxtype-moonshine-attention-mask.patch ];
  });
  voxtypeRuntimePackages = with pkgs; [
    wtype
    dotool
    wl-clipboard
    ydotool
    xdotool
    xclip
    libnotify
    pciutils
  ];
  voxtypePackage = pkgs.symlinkJoin {
    name = "voxtype-onnx-wrapped-${voxtypeUnwrapped.version}";
    paths = [ voxtypeUnwrapped ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/voxtype \
        --prefix PATH : ${pkgs.lib.makeBinPath voxtypeRuntimePackages} \
        --set ORT_DYLIB_PATH "${pkgs.onnxruntime}/lib/libonnxruntime.so" \
        --prefix LD_LIBRARY_PATH : "${pkgs.onnxruntime}/lib"
    '';
    inherit (voxtypeUnwrapped) meta;
  };
  moonshineModelRevision = "85ed015e3abbc51a129ea204c7ff3e812dedc9f5";
  moonshineModelBaseUrl = "https://huggingface.co/wmoto-ai/moonshine-tiny-ja-ONNX/resolve/${moonshineModelRevision}";
  moonshineEncoder = pkgs.fetchurl {
    name = "moonshine-tiny-ja-encoder-model-quantized.onnx";
    url = "${moonshineModelBaseUrl}/onnx/encoder_model_quantized.onnx";
    hash = "sha256-iFWbu8lWZvLCpF6HjBXt9SO55uq8p+s1cheP934dSa4=";
  };
  moonshineDecoder = pkgs.fetchurl {
    name = "moonshine-tiny-ja-decoder-model-merged-quantized.onnx";
    url = "${moonshineModelBaseUrl}/onnx/decoder_model_merged_quantized.onnx";
    hash = "sha256-N5FeGkej6KoRZWkehiq4tLqArUBMwkAbcKqBmXPqrJg=";
  };
  moonshineTokenizer = pkgs.fetchurl {
    name = "moonshine-tiny-ja-tokenizer.json";
    url = "${moonshineModelBaseUrl}/tokenizer.json";
    hash = "sha256-rTos6w6E5NpXRR2G+jN/gRbc/19dEGQ0+KoLDeiXGLk=";
  };
in
{
  home.packages = [
    voxtypePackage
    pkgs.wtype
  ];

  xdg.configFile."voxtype/config.toml".text = ''
    engine = "moonshine"
    state_file = "auto"

    [hotkey]
    enabled = false
    mode = "toggle"

    [audio]
    device = "default"
    sample_rate = 16000
    max_duration_secs = 60

    [moonshine]
    model = "tiny-ja"
    quantized = true
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

  home.file = {
    ".local/share/voxtype/models/moonshine-tiny-ja/encoder_model_quantized.onnx".source = moonshineEncoder;
    ".local/share/voxtype/models/moonshine-tiny-ja/decoder_model_merged_quantized.onnx".source = moonshineDecoder;
    ".local/share/voxtype/models/moonshine-tiny-ja/tokenizer.json".source = moonshineTokenizer;
  };

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
