# dotfiles

## NixOS
```
sudo nixos-rebuild switch --flake ./#wsl
```

### 開発時
確認
```
nix flake show ./wsl
sudo nixos-rebuild switch --flake ./#wsl
```

Home Manager で `/home/nixos/dotfiles/nvim-jetpack` を `~/.config/nvim` に symlink する。

### codex(unstable) をアップデートする手順
このリポジトリでは `nixpkgs-unstable` の入力を更新して `unstable.codex` を最新にします。

1) lock の更新
```
nix flake update nixpkgs-unstable
```

2) (任意) 反映予定のバージョン確認
```
nix eval --raw .#nixosConfigurations.nixos.pkgs.unstable.codex.version
```

3) 反映
```
sudo nixos-rebuild switch --flake .#wsl
```

## Codex skills
repo-managed skill は `codex/skills/` 配下に置く。

- custom skill: `codex/skills/<skill-name>/`
- public skill: `codex/skills/public/<skill-name>/`
- `SKILL.md` を持つディレクトリが skill として公開対象になる

- NixOS: `home/common.nix` が `SKILL.md` を持つ skill を `~/.codex/skills/...` に symlink し、`codex/AGENTS.md` を `~/.codex/AGENTS.md` に link する
- Windows: `windows/install.ps1` が相対パスを維持して `~/.codex/skills/...` の symlink を張る
- Windows: `windows/install.ps1` が `codex/AGENTS.md` を `~/.codex/AGENTS.md` に link する
- 既存の unmanaged skill が repo 側と同一内容なら、Windows では repo-managed な symlink に置き換える
- `.codex/skills/.system` や他のローカル skill はこの repo では管理しない

public skill を更新したいときは、`~/.codex/skills/public/<skill-name>/` から直接編集せず、この repo の `codex/skills/public/<skill-name>/` を更新する。

反映後は Codex を再起動する。
