# dotfiles

# NixOS
```
sudo nixos-rebuild switch --flake ./#nixos
```
## 開発時
確認
```
nix flake show
sudo nixos-rebuild switch --flake path:.#nixos
```

## Codex skills
custom skill は `codex/skills/<skill-name>/` に置く。

- NixOS: `nixos/home.nix` が `~/.codex/skills/<skill-name>` に公開する
- Windows: `windows/install.ps1` が `~/.codex/skills/<skill-name>` の symlink を張る
- `.codex/skills/.system` や他のローカル skill はこの repo では管理しない

反映後は Codex を再起動する。

