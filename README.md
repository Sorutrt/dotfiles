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

### 壁紙

`niri` 起動時に `awww-daemon` を起動する。壁紙は
`~/Pictures/Wallpaper/` に置き、`Mod+Shift+W` で開く rofi から選択する。

### 開発時
確認
```
nix eval .#nixosConfigurations.tpe14.config.system.build.toplevel.drvPath
sudo nixos-rebuild switch --flake ./#tpe14
```

Home Manager で `/home/nixos/dotfiles/nvim-jetpack` を `~/.config/nvim` に symlink する。

### tokf の更新

tokf のソースは `flake.lock` で固定している。更新するときは次を実行する。

```sh
nix flake update tokf
```

### Codex の更新

Codex は起動時には更新しない。最新版へ更新するときだけ、ログイン後に次を実行する。

```sh
update-codex
```


## Codex / Hermes skills
repo-managed skill は `agents/skills/` 配下に置き、Codex と Hermes で共有する。

- custom skill: `agents/skills/<skill-name>/`
- public skill: `agents/skills/public/<skill-name>/`
- `SKILL.md` を持つディレクトリが skill として公開対象になる

- NixOS: `home/common.nix` が `SKILL.md` を持つ skill を `~/.codex/skills/...` に symlink し、グローバル用の `codex/AGENTS.md` を `~/.codex/AGENTS.md` に link する
- NixOS: `home/hermes.nix` が同じ skill を `~/.hermes/skills/...` に symlink する
- NixOS: `home/common.nix` が `tokf hook install --global --tool codex` を activation で実行する
- Windows: `windows/install.ps1` が相対パスを維持して `~/.codex/skills/...` の symlink を張る
- Windows: `windows/install.ps1` がグローバル用の `codex/AGENTS.md` を `~/.codex/AGENTS.md` に link する
- Windows: `tokf` が PATH にある場合、`windows/install.ps1` が `tokf hook install --global --tool codex` を実行する
- 既存の unmanaged skill が repo 側と同一内容なら、Windows では repo-managed な symlink に置き換える
- `.codex/skills/.system` や他のローカル skill はこの repo では管理しない

dotfiles 固有の AI ルールはルートの `AGENTS.md` に置く。これはリポジトリルートで起動した Codex と Hermes の両方が読む。グローバルに配布する `codex/AGENTS.md` には Codex 向けの全プロジェクト共通ルールだけを書く。

public skill を更新したいときは、配布先から直接編集せず、この repo の `agents/skills/public/<skill-name>/` を更新する。

反映後は Codex を再起動する。Hermes では新しいセッションを開始するか、実行中のセッションで `/reload-skills` を実行する。
