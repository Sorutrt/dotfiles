---
name: dotfiles-maintainer
description: Repository-specific guidance for maintaining the 58kok dotfiles repo across NixOS and Windows. Use when Codex needs to update shell configs, editor configs, Home Manager settings, Windows install scripts, or Codex-related files in this repository.
---

# Dotfiles Maintainer

## Overview

Use this skill when editing this repository. Keep changes scoped to the target platform and preserve the current cross-platform layout.

## Repository Layout
- Put host-specific NixOS settings under `hosts/<host>/`.
- Put shared Home Manager settings in `home/common.nix`.
- Put host-specific Home Manager settings in `home/<host>.nix`.
- Put Windows setup logic under `windows/` and keep `windows/install.ps1` idempotent.
- Keep shell and editor config in existing top-level folders such as `nushell/`, `fish/`, `zsh/`, and `nvim-*`.
- Put repo-managed Codex skills under `codex/skills/<skill-name>/`.
- Put reusable public skills under `codex/skills/public/<skill-name>/`.

## Working Rules

- Inspect the target platform before editing. Do not assume a Linux change should affect Windows, or the reverse.
- Prefer symlink-friendly layouts and repository-relative sources when wiring files into home directories.
- When adding a new repo-managed Codex skill, ensure `home/common.nix` and `windows/install.ps1` continue to publish it into `~/.codex/skills/`.
- Update the root `README.md` when changing installation or synchronization behavior.
- Leave `.codex/skills/.system` and other unmanaged user-local Codex state untouched.
