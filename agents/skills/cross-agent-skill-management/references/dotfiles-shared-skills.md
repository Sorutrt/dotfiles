# Dotfiles Shared-Skill Layout

This repository keeps canonical shared skills under:

```text
agents/skills/
├── <custom-skill>/
└── public/<public-skill>/
```

## Consumers

- Home Manager recursively finds directories containing `SKILL.md`.
- Codex receives source-relative links under `~/.codex/skills/`.
- Hermes receives the same source-relative links under `~/.hermes/skills/`.
- Windows Codex setup uses `agents\skills` as the source and `.codex\skills` as the consumer target.
- `codex/AGENTS.md` remains Codex-specific global context; the repository-root `AGENTS.md` is shared project context.

## Rename checklist

When moving a tool-branded source tree such as `codex/skills/` to the neutral root:

1. Move all skill directories, including support files and `agents/openai.yaml` metadata.
2. Update `.gitignore` allow rules so the new tree remains tracked.
3. Update Nix source roots for both Codex and Hermes.
4. Update the Windows installer source root.
5. Update README, root rules, and skill-internal path references.
6. Search specifically for stale repository-source forms such as `dotfiles/codex/skills`, `../codex/skills`, and `repoRoot "codex\\skills"`; do not mistake valid target paths under `~/.codex/skills/` for stale source references.
7. Repoint only repository-managed live symlinks.

## Targeted probe

Use an OS-safe temporary `/tmp/hermes-verify-*` script that:

- discovers all `SKILL.md` files below `agents/skills/`;
- confirms the old source tree is absent;
- checks both publication roots are symlinks resolving to each source directory;
- checks Nix source-root declarations and the Windows source-root literal;
- builds the affected Home Manager activation package;
- runs a diff whitespace check;
- confirms Hermes lists each shared skill;
- removes itself in a `finally` block.

Report the result as ad-hoc targeted verification rather than claiming the complete repository suite is green.
