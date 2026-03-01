# nix-config

```
sudo nixos-rebuild switch --flake ./#nixos
```
## 開発時
確認
```
nix flake show
sudo nixos-rebuild switch --flake path:.#nixos
```

## codex(unstable) をアップデートする手順
このリポジトリでは `nixpkgs-unstable` の入力を更新して `unstable.codex` を最新にします。

1) lock の更新
```
nix flake update --update-input nixpkgs-unstable
```

2) (任意) 反映予定のバージョン確認
```
nix eval --raw .#nixosConfigurations.nixos.pkgs.unstable.codex.version
```

3) 反映
```
sudo nixos-rebuild switch --flake .#nixos
```
