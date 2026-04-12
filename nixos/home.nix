{ config, lib, pkgs, ... }:

let
  codexSkillRoot = ../codex/skills;
  nvimConfigRoot = "${config.home.homeDirectory}/dotfiles/nvim-jetpack";
  managedCodexSkills =
    lib.unique (
      map
        (skillFile:
          lib.removePrefix
            "${toString codexSkillRoot}/"
            (builtins.toString (builtins.dirOf skillFile))
        )
        (
          lib.filter
            (path: builtins.baseNameOf path == "SKILL.md")
            (lib.filesystem.listFilesRecursive codexSkillRoot)
        )
    );
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
    {
      ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink nvimConfigRoot;
      };
    }
    // builtins.listToAttrs (
      map
        (relativePath:
          lib.nameValuePair ".codex/skills/${relativePath}" {
            source = codexSkillRoot + "/${relativePath}";
          })
        managedCodexSkills
    );

  programs.home-manager.enable = true;
}
