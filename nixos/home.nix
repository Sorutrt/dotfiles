{ config, lib, pkgs, ... }:

let
  codexSkillRoot = ../codex/skills;
  managedCodexSkills =
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir codexSkillRoot);
in
{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    # common tools
    wget
    unstable.fzf

    # VCS
    git
    lazygit
    unstable.jujutsu

    # AI
    unstable.codex

    # Editor
    vim
    neovim

    # Shell
    nushell

    # CLI
    nnn
    starship

    mise

    # 処理系
    gcc
    python312
    nodejs_24
  ];

  home.file =
    lib.mapAttrs'
      (name: _: lib.nameValuePair ".codex/skills/${name}" {
        source = codexSkillRoot + "/${name}";
      })
      managedCodexSkills;

  programs.home-manager.enable = true;
}
