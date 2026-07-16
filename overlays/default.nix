{ nixpkgs-unstable }:
{ ... }:
{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.system;
        config = prev.config; # allowUnfree などを引き継ぎ
      };
      tokf = final.rustPlatform.buildRustPackage rec {
        pname = "tokf";
        version = "0.2.49";

        src = final.fetchFromGitHub {
          owner = "mpecan";
          repo = "tokf";
          rev = "tokf-v${version}";
          hash = "sha256-3jE2Wo5FyNML/WjfW4EmiOpEAMu58u8xZBje6S3GhfY=";
        };

        cargoHash = "sha256-lPfGtogLld3isO/pPD5KUAFpaZud/KaQf8j6PB9a6Hg=";

        cargoBuildFlags = [ "-p" "tokf" ];
        doCheck = false;
      };
    })
  ];
}
