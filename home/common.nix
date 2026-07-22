{ config, lib, pkgs, ... }:

let
  updateCodex = pkgs.writeShellApplication {
    name = "update-codex";
    runtimeInputs = [ pkgs.nodejs_24 ];
    text = ''
      export HOME="${config.home.homeDirectory}"
      export NPM_CONFIG_PREFIX="$HOME/.local"
      export PATH="$HOME/.local/bin:$PATH"

      mkdir -p "$HOME/.local"

      npm install -g @openai/codex@latest
      codex --version
    '';
  };

  codexAgentsFile = "${config.home.homeDirectory}/dotfiles/codex/AGENTS.md";
  sharedSkillRoot = "${config.home.homeDirectory}/dotfiles/agents/skills";
  sharedSkillSourceRoot = ../agents/skills;
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

  codexSkillDirs = findCodexSkillDirs "" sharedSkillSourceRoot;

  codexSkillFiles =
    lib.listToAttrs (
      map
        (relativePath: {
          name = ".codex/skills/${relativePath}";
          value = {
            force = true;
            source = config.lib.file.mkOutOfStoreSymlink "${sharedSkillRoot}/${relativePath}";
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
    # pkgs.codex is old. Use update-codex to install the latest release on demand.
    bubblewrap
    tokf
    updateCodex

    # Editor
    vim
    neovim

    # CLI
    nnn
    starship
    glow

    unstable.mise
    p7zip

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

  home.activation.installTokfCodexHook =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.tokf}/bin/tokf hook install --global --tool codex
    '';

  programs.nushell.enable = true;
  programs.home-manager.enable = true;
}
