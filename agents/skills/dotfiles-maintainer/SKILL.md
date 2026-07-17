---
name: dotfiles-maintainer
description: Repository-specific guidance for maintaining the 58kok dotfiles repo across NixOS and Windows. Use when a coding agent needs to update shell configs, editor configs, Home Manager settings, Windows install scripts, or agent-related files in this repository.
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
- Put repo-managed shared agent skills under `agents/skills/<skill-name>/`.
- Put reusable public skills under `agents/skills/public/<skill-name>/`.

## Working Rules

- Inspect the target platform before editing. Do not assume a Linux change should affect Windows, or the reverse.
- Prefer symlink-friendly layouts and repository-relative sources when wiring files into home directories.
- Keep application settings in ordinary config files in this repository when the application supports them. Do not encode those settings directly as Nix attribute sets unless no usable config file exists or the user explicitly requests it.
- Publish XDG config files with `xdg.configFile` and other home-relative config files with `home.file`. Prefer `mkOutOfStoreSymlink` when the file should remain directly editable from the repository.
- When adding a new repo-managed shared skill, ensure Home Manager continues to publish it to both `~/.codex/skills/` and `~/.hermes/skills/`.
- Update the root `README.md` when changing installation or synchronization behavior.
- Leave `.codex/skills/.system` and other unmanaged user-local Codex or Hermes state untouched.

## CI and Tests

- Keep CI focused on fast checks and behavior that must not break. Prefer Nix evaluation/build-plan checks plus small tests for extracted core logic over running full setup scripts.
- Do not put `windows/install.ps1`, `winget`, or `git clone` installation paths in CI unless explicitly requested. Test reusable logic under `windows/lib/` instead.
- Prefer PowerShell tests that run with only `pwsh`. `nixpkgs#powershell` provides PowerShell but not Pester, and `nix search nixpkgs pester --json` returned no package in this repo's environment.
- Validate PowerShell tests locally with:
  `nix shell nixpkgs#powershell -c pwsh -NoProfile -Command '$testScripts = @("windows/tests/Links.Tests.ps1", "windows/tests/CodexSkills.Tests.ps1"); foreach ($testScript in $testScripts) { & $testScript }'`
- When running Windows behavior tests on Linux through `nixpkgs#powershell`, skip Windows-specific filesystem operations such as junction creation, but keep them active in `windows-latest` CI.
- If `nix shell` or `nix search` fails in the sandbox because it cannot access the Nix daemon or `/home/nixos/.cache/nix`, rerun the same command with the required sandbox escalation instead of changing the test approach.
