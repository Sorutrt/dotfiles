---
name: cross-agent-skill-management
description: Share and publish one skill library across coding agents.
version: 1.0.0
metadata:
  hermes:
    tags: [skills, codex, hermes, dotfiles, symlinks]
---

# Cross-Agent Skill Management

## When to Use

Use this skill when one repository owns procedural skills consumed by multiple coding agents, or when renaming, publishing, or validating that shared library.

Do not use it for a skill that genuinely belongs to one agent only; keep tool-specific configuration in that tool's own directory.

## Design Principles

- Give the canonical source a tool-neutral name such as `agents/skills/`. A source path named after one consumer falsely implies ownership and becomes awkward as more agents are added.
- Keep one editable source tree and publish it to each agent's expected discovery path.
- Preserve namespaces and support files (`references/`, `templates/`, `scripts/`, `assets/`) when publishing a skill directory.
- Treat project context and reusable skills separately: a repository-root `AGENTS.md` can be shared project context, while global context contracts may remain tool-specific.
- Never overwrite unrelated bundled, hub-installed, or user-local skills. Replace only links or files demonstrably managed by the repository.

For a concrete dotfiles layout and rename verification recipe, see `references/dotfiles-shared-skills.md`.

## Procedure

1. Discover every source directory containing `SKILL.md` recursively.
2. Identify each consumer's target root and whether it supports direct external directories, symlinks, or copied installs.
3. Prefer out-of-store or ordinary symlinks when source edits should be visible immediately.
4. Preserve each source-relative path at every target, including category directories.
5. When renaming the canonical source root, update ignore allowlists, platform installers, declarative configuration, documentation, and skill-internal path references.
6. Repoint only currently managed links so the active environment does not remain broken until the next configuration activation.
7. Search for stale source-path references. Distinguish them from valid consumer target paths such as `~/.codex/skills/`.
8. Verify both declarative generation and live agent discovery.

## Pitfalls

- Do not assume the latest documentation describes the currently pinned agent version. Verify the installed implementation before relying on newer configuration features; use the supported publication mechanism for that version.
- A successful configuration evaluation does not prove live discovery. Check the generated links and ask each agent to list or load representative skills.
- Moving a source directory can leave existing symlinks dangling even when the next declarative build is correct. Repair managed live links as part of the rename.
- Do not report a focused temporary probe as the full test suite passing. Label it ad-hoc or targeted verification.
- Avoid leaving compatibility paths under the old tool-branded directory merely to hide broken links; update managed consumers to the neutral source instead.

## Verification

For a layout change, verify all of the following:

- the old canonical source path is absent;
- every `SKILL.md` source has the expected published link for each consumer;
- each link resolves to the canonical source directory;
- the relevant declarative configuration evaluates or builds;
- each agent lists or loads the shared skills;
- stale canonical-source references are absent;
- unrelated local skills remain untouched.

For non-canonical repositories, use an OS-safe temporary verification script (for example, a `tempfile`-generated path) and remove it after execution.
