{ nixpkgs-unstable, tokf }:
{ ... }:
{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.stdenv.hostPlatform.system;
        config = prev.config; # allowUnfree などを引き継ぎ
      };
      tokf = final.rustPlatform.buildRustPackage {
        pname = "tokf";
        version = (builtins.fromTOML (builtins.readFile "${tokf}/crates/tokf-cli/Cargo.toml")).package.version;

        src = tokf;
        cargoLock = {
          lockFile = "${tokf}/Cargo.lock";
        };

        cargoBuildFlags = [ "-p" "tokf" ];
        doCheck = false;
      };
    })
  ];
}
