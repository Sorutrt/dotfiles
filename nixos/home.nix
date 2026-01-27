{ config, pkgs, ... }:

{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    # common tools
    wget
    vim

    # VCS
    git
    lazygit
    unstable.jujutsu

    # AI
    codex

    # CLI
    nnn
    nushell
    starship
  ];

  programs.home-manager.enable = true;
}
