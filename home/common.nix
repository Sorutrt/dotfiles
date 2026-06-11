{ config, lib, pkgs, ... }:

let
  codexSkillRoot = "${config.home.homeDirectory}/dotfiles/codex/skills";
  codexSkillSourceRoot = ../codex/skills;
  nvimConfigRoot = "${config.home.homeDirectory}/dotfiles/nvim-jetpack";

  findCodexSkillDirs =
    relativePath: path:
    lib.concatLists (
      lib.mapAttrsToList
        (name: type:
          let
            childRelativePath =
              if relativePath == "" then name else "${relativePath}/${name}";
            childPath = path + "/${name}";
          in
          if type == "directory" then
            (lib.optional (builtins.pathExists (childPath + "/SKILL.md")) childRelativePath)
            ++ findCodexSkillDirs childRelativePath childPath
          else
            [ ])
        (builtins.readDir path)
    );

  codexSkillDirs = findCodexSkillDirs "" codexSkillSourceRoot;

  codexSkillFiles =
    lib.listToAttrs (
      map
        (relativePath: {
          name = ".codex/skills/${relativePath}";
          value = {
            force = true;
            source = config.lib.file.mkOutOfStoreSymlink "${codexSkillRoot}/${relativePath}";
          };
        })
        codexSkillDirs
    );
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
    }
    // codexSkillFiles;

  home.activation.relinkNvimConfig =
    lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
      nvimConfigTarget="$HOME/.config/nvim"
      if [[ -e "$nvimConfigTarget" || -L "$nvimConfigTarget" ]]; then
        run rm -rf "$nvimConfigTarget"
      fi
    '';

  programs.home-manager.enable = true;
}
