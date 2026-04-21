# dotfiles

# NixOS
```
sudo nixos-rebuild switch --flake ./nixos#nixos
```
## 開発時
確認
```
nix flake show ./nixos
sudo nixos-rebuild switch --flake ./nixos#nixos
```

Home Manager で `/home/nixos/dotfiles/nvim-jetpack` を `~/.config/nvim` に symlink する。

## Codex skills
repo-managed skill は `codex/skills/` 配下に置く。

- custom skill: `codex/skills/<skill-name>/`
- public skill: `codex/skills/public/<skill-name>/`
- `SKILL.md` を持つディレクトリが skill として公開対象になる

- NixOS: `nixos/home.nix` の activation が相対パスを維持して `~/.codex/skills/...` の symlink を張る
- Windows: `windows/install.ps1` が相対パスを維持して `~/.codex/skills/...` の symlink を張る
- 既存の unmanaged skill が repo 側と同一内容なら、Windows では repo-managed な symlink に置き換える
- `.codex/skills/.system` や他のローカル skill はこの repo では管理しない

public skill を更新したいときは、`~/.codex/skills/public/<skill-name>/` から直接編集せず、この repo の `codex/skills/public/<skill-name>/` を更新する。

反映後は Codex を再起動する。

