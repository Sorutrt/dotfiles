# dotfiles

## NixOS
```
sudo nixos-rebuild switch --flake ./#wsl
```

### mba2013

反映:
```
sudo nixos-rebuild switch --flake .#mba2013
```

確認:
```
systemctl status niri
```

### 開発時
確認
```
nix flake show ./wsl
sudo nixos-rebuild switch --flake ./#wsl
```

Home Manager で `/home/nixos/dotfiles/nvim-jetpack` を `~/.config/nvim` に symlink する。


## Codex skills
repo-managed skill は `codex/skills/` 配下に置く。

- custom skill: `codex/skills/<skill-name>/`
- public skill: `codex/skills/public/<skill-name>/`
- `SKILL.md` を持つディレクトリが skill として公開対象になる

- NixOS: `home/common.nix` が `SKILL.md` を持つ skill を `~/.codex/skills/...` に symlink し、グローバル用の `codex/AGENTS.md` を `~/.codex/AGENTS.md` に link する
- NixOS: `home/common.nix` が `tokf hook install --global --tool codex` を activation で実行する
- Windows: `windows/install.ps1` が相対パスを維持して `~/.codex/skills/...` の symlink を張る
- Windows: `windows/install.ps1` がグローバル用の `codex/AGENTS.md` を `~/.codex/AGENTS.md` に link する
- Windows: `tokf` が PATH にある場合、`windows/install.ps1` が `tokf hook install --global --tool codex` を実行する
- 既存の unmanaged skill が repo 側と同一内容なら、Windows では repo-managed な symlink に置き換える
- `.codex/skills/.system` や他のローカル skill はこの repo では管理しない

dotfiles 固有の AI ルールはルートの `AGENTS.md` に置き、グローバルに配布する `codex/AGENTS.md` には全プロジェクト共通の最小ルールだけを書く。

public skill を更新したいときは、`~/.codex/skills/public/<skill-name>/` から直接編集せず、この repo の `codex/skills/public/<skill-name>/` を更新する。

反映後は Codex を再起動する。
