{ config, lib, pkgs, ... }:

let
  installOrUpdateCodex = pkgs.writeShellScriptBin "install-or-update-codex" ''
    set -u

    export HOME="${config.home.homeDirectory}"
    export NPM_CONFIG_PREFIX="$HOME/.local"
    export PATH="${lib.makeBinPath [
      pkgs.nodejs_24
      pkgs.coreutils
    ]}:$HOME/.local/bin:$PATH"

    mkdir -p "$HOME/.local"

    if npm install -g @openai/codex@latest; then
      if command -v codex >/dev/null 2>&1; then
        codex --version || true
      fi
    else
      echo "warning: failed to install/update Codex; keeping existing installation if any" >&2
      exit 0
    fi
  '';

  codexAgentsFile = "${config.home.homeDirectory}/dotfiles/codex/AGENTS.md";
  codexSkillRoot = "${config.home.homeDirectory}/dotfiles/codex/skills";
  codexSkillSourceRoot = ../codex/skills;
  nvimConfigRoot = "${config.home.homeDirectory}/dotfiles/nvim-jetpack";
  nushellConfigFile = "${config.home.homeDirectory}/dotfiles/nushell/config.nu";

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
    ripgrep

    # VCS
    git
    lazygit
    unstable.jujutsu
    actionlint

    # AI
    # pkgs.codex is old, so install/update Codex manually with install-or-update-codex.
    installOrUpdateCodex

    # Editor
    vim
    neovim

    # CLI
    nnn
    starship
    glow

    unstable.mise

    # 処理系
    gcc
    python312
    nodejs_24
    gnumake
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  home.file =
    {
      ".config/nvim" = {
        force = true;
        source = config.lib.file.mkOutOfStoreSymlink nvimConfigRoot;
      };
      ".config/nushell/config.nu" = {
        force = true;
        source = config.lib.file.mkOutOfStoreSymlink nushellConfigFile;
      };
      ".codex/AGENTS.md" = {
        force = true;
        source = config.lib.file.mkOutOfStoreSymlink codexAgentsFile;
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

  programs.nushell.enable = true;
  programs.home-manager.enable = true;
}
