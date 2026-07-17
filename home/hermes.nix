{ config, inputs, lib, pkgs, ... }:

let
  hermesPackage = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
  sharedSkillRoot = "${config.home.homeDirectory}/dotfiles/agents/skills";
  sharedSkillSourceRoot = ../agents/skills;

  findSharedSkillDirs =
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
            ++ findSharedSkillDirs childRelativePath childPath
          else
            [ ])
        (builtins.readDir path)
    );

  hermesSkillFiles =
    lib.listToAttrs (
      map
        (relativePath: {
          name = ".hermes/skills/${relativePath}";
          value = {
            force = true;
            source = config.lib.file.mkOutOfStoreSymlink "${sharedSkillRoot}/${relativePath}";
          };
        })
        (findSharedSkillDirs "" sharedSkillSourceRoot)
    );
in
{
  home.packages = [
    hermesPackage
  ];

  home.file = hermesSkillFiles;
}

