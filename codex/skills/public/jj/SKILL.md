---
name: jj
description: Jujutsu (jj) の日常コマンド早見表。基本操作の確認に使う。
---

# JJ Quick Command List

A compact cheat-sheet for day-to-day **Jujutsu (`jj`)** work in this environment.

## Common Commands

| Purpose | Command | What it does |
| --- | --- | --- |
| See changes | `jj status` | Show working-copy commit and file modifications |
| Browse history | `jj log` | One-line graph of revisions |
| Diff current work | `jj diff` | Compare working copy to its parent |
| Start a new change | `jj new` | Fork a fresh change from `@` |
| Write/update message | `jj describe -m "msg"` | Set the description of the working change |
| Split hunks interactively | `jj split` | Carve the current change into smaller ones |
| Discard the current change | `jj abandon` | Abandon `@` and create a clean working-copy commit on its parent |
| Undo last operation | `jj undo` | Revert a recent operation via the op log |
| List operations | `jj op log` | Show operation history |
| Push | `jj git push` | Push through Git remotes |
| Fetch/import from Git remote | `jj git fetch` | Update remote-tracking refs from Git remotes |
| Rebase current change | `jj rebase -d <rev>` | Move current work onto another revision |
| List bookmarks | `jj bookmark list` | Show bookmarks |
| Create bookmark | `jj bookmark create <name>` | Add a bookmark to the current revision |
| Move bookmark | `jj bookmark move <name> --to <rev>` | Repoint an existing bookmark |
| Delete bookmark | `jj bookmark delete <name>` | Remove bookmark label |

## Git To JJ Mappings

| Git habit | Prefer in jj |
| --- | --- |
| `git status` | `jj status` |
| `git diff` | `jj diff` |
| `git log --oneline --graph` | `jj log` |
| `git commit -m "msg"` | `jj describe -m "msg"` |
| create a branch | `jj bookmark create <name>` |
| move a branch pointer | `jj bookmark move <name> --to <rev>` |
| `git push` | `jj git push` |
| inspect recovery options | `jj op log` then `jj undo` |

## Guardrails

- Use `jj` as the default VCS interface for this project.
- Use `git` only when a read-only compatibility check or an external integration requires it.
- To discard an entirely incorrect working-copy change, inspect `jj status` and `jj diff`, then run `jj abandon`. Use `jj restore` or partial editing instead when any part must be kept.
- Before doing a task that is obvious in Git but unclear in `jj`, look up the `jj` workflow first.
- After learning a new `jj` workflow, add the result here with prerequisites, caveats, and an example when useful.
- After a `jj` failure, record the symptom, cause, corrected workflow, and a next-time guardrail here.

## Environment Checks

Run these before assuming `jj` is usable in a shell:

- `Get-Command jj -ErrorAction SilentlyContinue`
- `where.exe jj`

If both fail, treat `jj` as unavailable in the current shell and fix the environment before relying on repo-local `jj` workflows.

## Failure Log

### 2026-06-23: `jj describe --no-editor` is not supported in jj 0.42.0

- Symptom: `jj describe --no-editor -m "..."` failed with `unexpected argument '--no-editor' found`.
- Cause: jj 0.42.0 does not provide `--no-editor`; `-m/--message` already sets the description without opening an editor unless `--editor` is passed.
- Corrected workflow: use `jj describe -m "msg"` for headless description updates.
- Guardrail: check `jj describe --help` before adding editor-related flags across jj versions.

### 2026-06-19: `jj` lock creation can fail from sandboxed `codex/` cwd

- Symptom: `jj file list` or other read-looking commands fail with `Failed to take lock for Git import/export` and `Read-only file system`.
- Cause: the jj repository root is `/home/nixos/dotfiles`, but a Codex session may start in `/home/nixos/dotfiles/codex` with write access only under `codex/`; jj still needs to write locks under `/home/nixos/dotfiles/.jj`.
- Corrected workflow: run jj from the repository root and request escalation when the command needs to snapshot or touch `.jj` locks.
- Guardrail: do not retry the same jj command unescorted after this error; either rerun with scoped escalation or use `git status --short` only as a read-only compatibility check.

### 2026-06-19: Empty `codex/.git` makes jj report tracked files as deleted

- Symptom: `jj status` reports tracked `codex/` files as deleted while `git status --short` only reports modified files.
- Cause: empty special directories such as `codex/.git`, `codex/.agents`, and `codex/.codex` can appear in the Codex workspace; jj treats `codex/.git` as a nested repository boundary and skips snapshotting `codex/`.
- Corrected workflow: confirm with `find codex -maxdepth 2 -type d -name .git -o -name .agents -o -name .codex`, remove those empty directories with `rmdir`, then rerun `jj status`.
- Guardrail: when jj and git disagree about `codex/` files, check for these empty directories before trying `jj restore`, `jj file track`, or repeated status commands.

### 2026-05-14: `jj` not on PATH in Codex PowerShell

- Symptom: running `jj status` returned `The term 'jj' is not recognized as a name of a cmdlet, function, script file, or executable program.`
- Cause: `jj` was not available on the PowerShell `PATH` in this Codex environment.
- Corrected workflow: verify availability with `Get-Command jj` or `where.exe jj` before assuming `jj` commands can run.
- Guardrail: if `jj` is unavailable, do not silently switch to `git` for normal project workflow; either expose/install `jj` first or explicitly document the exception.

## Safety Net

- `jj op restore <op-id>` can restore the repository to a previous operation.
- Everything is designed to be recoverable; when in doubt, inspect `jj op log` before making a larger recovery move.

## Automation Tips

- For `jj describe`, pass `-m "msg"` in headless flows. In jj 0.42.0, `--no-editor` is not supported and `-m/--message` already avoids opening an editor.
- Prefer stable, template-based output when a tool needs to parse `jj` results.
