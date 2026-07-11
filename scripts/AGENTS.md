# scripts — Install/Uninstall Scripts

## Purpose

Install and uninstall scripts for both agent ports:
OpenCode (`.opencode/agents/`) and Claude Code (`.claude/agents/`).

## Ownership

- `install.sh` / `install.ps1` — copy agent files to global or local target
- `uninstall.sh` / `uninstall.ps1` — remove agent files from global or local target

## Local Contracts

Interface (identical for install and uninstall, `.sh` and `.ps1`):

```text
install.sh|install.ps1   <opencode|claude|all> [--global|--local]
uninstall.sh|uninstall.ps1 <opencode|claude|all> [--global|--local]
```

Default target is `--global`.

Path mapping:

| Tool | global | local |
| --- | --- | --- |
| opencode | `~/.config/opencode/agents/` | `./.opencode/agents/` |
| claude | `~/.claude/agents/` | `./.claude/agents/` |

Explicit file lists (the only files scripts may touch):

- opencode: `flow.md`, `subflow.md`, `player.md`, `coach.md`
- claude: `flow.md`, `player.md`, `coach.md`

Guarantees:

- Install copies/overwrites only its own files by name from the explicit
  list; foreign files in the target are never touched.
- Uninstall removes strictly by the explicit file list — never by glob/mask;
  empty directories are left in place; idempotent (repeat runs succeed).
- Local install from inside this repository is a no-op:
  skip when source == destination.
- Scripts resolve the repo root from their own path and work from a clone
  in any directory.

## Work Guidance

- Never use `cp -r "$src/agents/" "$dest/"` — GNU cp ignores the trailing
  slash on the source; copy file-by-file from the explicit list only.
- `.ps1` scripts mirror `.sh` behavior exactly; any behavior change lands
  in both pairs in the same change.

## Verification

Full cycle on macOS: install → repeat install → uninstall → repeat uninstall
for each tool and each target; no leftover files, no foreign files removed,
no failures on repeat runs.

## Child DOX Index

None.
