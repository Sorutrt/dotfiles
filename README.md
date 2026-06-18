# dotfiles

## NixOS
```
sudo nixos-rebuild switch --flake ./#wsl
```

### mba2013 kanata
`mba2013` では kanata を system service として起動する。通常ユーザーには `input` / `uinput` グループを付けず、専用 system user の `kanata` だけが入力デバイスと `/dev/uinput` にアクセスする。

反映:
```
sudo nixos-rebuild switch --flake .#mba2013
```

確認:
```
systemctl status kanata
journalctl -u kanata -b
ls -l /dev/uinput
id sorutrt
id kanata
```

keymap は `kanata/kanata.kbd` で管理し、NixOS が `/etc/kanata.kbd` に配置する。まずは CapsLock 単押し Esc、長押し Ctrl の最小設定にしている。

読み取り対象キーボードを明示的に絞る場合は、実機で次を確認して `hosts/mba2013/kanata.nix` の `keyboardDevices` に `event-kbd` のパスを追加する。
```
ls -l /dev/input/by-id/ /dev/input/by-path/
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
