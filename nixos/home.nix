{ config, pkgs, ... }:

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

  programs.home-manager.enable = true;
}
