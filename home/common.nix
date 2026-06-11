{ config, lib, pkgs, ... }:

let
  codexSkillRoot = "${config.home.homeDirectory}/dotfiles/codex/skills";
  nvimConfigRoot = "${config.home.homeDirectory}/dotfiles/nvim-jetpack";
in
{
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

    unstable.mise

    # 処理系
    gcc
    python312
    nodejs_24
    gnumake
  ];

  home.file =
    {
      ".config/nvim" = {
        force = true;
        source = config.lib.file.mkOutOfStoreSymlink nvimConfigRoot;
      };
      ".codex/skills" = {
        force = true;
        source = config.lib.file.mkOutOfStoreSymlink codexSkillRoot;
      };
    };

  home.activation.relinkNvimConfig =
    lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
      nvimConfigTarget="$HOME/.config/nvim"
      if [[ -e "$nvimConfigTarget" || -L "$nvimConfigTarget" ]]; then
        run rm -rf "$nvimConfigTarget"
      fi
    '';

  programs.home-manager.enable = true;
}
