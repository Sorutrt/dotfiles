{ config, lib, pkgs, ... }:

let
  codexSkillRoot = "${config.home.homeDirectory}/dotfiles/codex/skills";
  nvimConfigRoot = "${config.home.homeDirectory}/dotfiles/nvim-jetpack";
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
        force = true;
        source = config.lib.file.mkOutOfStoreSymlink nvimConfigRoot;
      };
    };

  home.activation.relinkNvimConfig =
    lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
      nvimConfigTarget="$HOME/.config/nvim"
      if [[ -e "$nvimConfigTarget" || -L "$nvimConfigTarget" ]]; then
        run rm -rf "$nvimConfigTarget"
      fi
    '';

  home.activation.linkCodexSkills =
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      codexSkillRoot="${codexSkillRoot}"
      codexSkillsTarget="$HOME/.codex/skills"

      if [[ -d "$codexSkillRoot" ]]; then
        run mkdir -p "$codexSkillsTarget"

        while IFS= read -r -d "" existingLink; do
          linkTarget="$(${pkgs.coreutils}/bin/readlink "$existingLink")"
          if [[ "$linkTarget" == "$codexSkillRoot/"* && ! -e "$linkTarget/SKILL.md" ]]; then
            run rm "$existingLink"
          fi
        done < <(${pkgs.findutils}/bin/find "$codexSkillsTarget" -type l -print0)

        while IFS= read -r -d "" skillFile; do
          skillDir="''${skillFile%/SKILL.md}"
          relativePath="''${skillDir#$codexSkillRoot/}"
          targetSkillDir="$codexSkillsTarget/$relativePath"
          targetParentDir="''${targetSkillDir%/*}"

          run mkdir -p "$targetParentDir"

          if [[ -e "$targetSkillDir" || -L "$targetSkillDir" ]]; then
            if [[ -L "$targetSkillDir" ]]; then
              currentTarget="$(${pkgs.coreutils}/bin/readlink "$targetSkillDir")"
              if [[ "$currentTarget" == "$skillDir" ]]; then
                continue
              fi

              if [[ "$currentTarget" == "$codexSkillRoot/"* ]]; then
                run rm "$targetSkillDir"
              else
                echo "Skipping existing unmanaged Codex skill: $targetSkillDir" >&2
                continue
              fi
            elif [[ -d "$targetSkillDir" ]] && ${pkgs.diffutils}/bin/diff -qr "$skillDir" "$targetSkillDir" >/dev/null; then
              run rm -rf "$targetSkillDir"
            else
              echo "Skipping existing unmanaged Codex skill: $targetSkillDir" >&2
              continue
            fi
          fi

          run ln -s "$skillDir" "$targetSkillDir"
        done < <(${pkgs.findutils}/bin/find "$codexSkillRoot" -name SKILL.md -type f -print0)
      fi
    '';

  programs.home-manager.enable = true;
}
