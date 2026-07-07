# g3-agents-opencode — Multi-Agent Orchestration for OpenCode

A set of agent configs (agents) for OpenCode with mediation, recursive task decomposition, and zero-tolerance review. No dependency installation required.

## 📋 Purpose

The system implements mediated multi-agent orchestration: four roles interact through a strict contract via an orchestrator (`@flow`), which decides on task decomposition, delegation, and reviewer verdicts. Agents **never communicate directly** — all inter-agent communication goes through `@flow`.

## 🚀 Getting Started

This project requires no dependency installation — once the `agents/` directory is in place, OpenCode automatically discovers agents via YAML front-matter in compatible runtimes (e.g. Claude Code, OpenCode Skills).

Send tasks to `@flow` — the orchestrator handles decomposition and coordination. A realistic flow with revision cycles:

```
@flow → decomposition → @player (first version) → @coach → REVISE
→ @player (revised code) → @coach → ACCEPT
→ @flow collects results, requests merged review → done
```

## 📥 Installation

### Global (all projects)

Agents are installed to `~/.config/opencode/agents/` and available in every project.

**macOS / Linux:**

```bash
tmpdir=$(mktemp -d) && \
git clone https://github.com/BlackLik/g3-agents-opencode.git "$tmpdir" && \
mkdir -p ~/.config/opencode/agents && \
cp -r "$tmpdir/agents/" ~/.config/opencode/agents/ && \
rm -rf "$tmpdir"
```

**Windows (PowerShell):**

```powershell
$tmpdir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
git clone https://github.com/BlackLik/g3-agents-opencode.git $tmpdir
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\opencode\agents"
Copy-Item -Path "$tmpdir\agents\*" -Destination "$env:USERPROFILE\.config\opencode\agents\" -Recurse -Force
Remove-Item -Recurse -Force $tmpdir
```

### Local (current project)

Agents are installed to `./agents/` in your project root.

**macOS / Linux:**

```bash
tmpdir=$(mktemp -d) && \
git clone https://github.com/BlackLik/g3-agents-opencode.git "$tmpdir" && \
mkdir -p ./agents && \
cp -r "$tmpdir/agents/" ./agents/ && \
rm -rf "$tmpdir"
```

**Windows (PowerShell):**

```powershell
$tmpdir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
git clone https://github.com/BlackLik/g3-agents-opencode.git $tmpdir
New-Item -ItemType Directory -Force -Path "./agents"
Copy-Item -Path "$tmpdir\agents\*" -Destination "./agents/" -Recurse -Force
Remove-Item -Recurse -Force $tmpdir
```

> **Note:** Installation only copies/overwrites files from the repository — your existing agents are never deleted.

## 🗑 Uninstall

> **Caution:** These commands permanently delete files. Verify the path before running.

### Global (all projects)

Removes agents from `~/.config/opencode/agents/`.

**macOS / Linux:**

```bash
rm -f ~/.config/opencode/agents/{AGENTS.md,flow.md,player.md,coach.md,subflow.md}
```

**Windows (PowerShell):**

```powershell
Remove-Item "$env:USERPROFILE\.config\opencode\agents\AGENTS.md", "$env:USERPROFILE\.config\opencode\agents\flow.md", "$env:USERPROFILE\.config\opencode\agents\player.md", "$env:USERPROFILE\.config\opencode\agents\coach.md", "$env:USERPROFILE\.config\opencode\agents\subflow.md" -ErrorAction SilentlyContinue
```

### Local (current project)

Removes agents from `./agents/` in your project root.

**macOS / Linux:**

```bash
rm -f ./agents/{AGENTS.md,flow.md,player.md,coach.md,subflow.md}
```

**Windows (PowerShell):**

```powershell
Remove-Item "./agents/AGENTS.md", "./agents/flow.md", "./agents/player.md", "./agents/coach.md", "./agents/subflow.md" -ErrorAction SilentlyContinue
```

## 🏗 Architecture

```
User → @flow (orchestrator) → @player (executor) → @coach (reviewer)
         ↑                                                        │
         └──── @flow evaluates coach verdict: ACCEPT→done          ↓
                  REVISE/REJECT → instruction to player────────────┘
```

`@coach` **never sends** revisions directly to `@player`. All verdicts go through `@flow`, which decides whether to continue the cycle or terminate.

## ⚙️ How It Works

The orchestrator decomposes tasks by complexity and caps recursion at depth 2. After all subtasks complete, a final merged review is requested from `@coach`.

## 📐 Depth System

A depth system controls recursion:

| Depth | Description | Behavior |
|---|---|---|
| **0** | Top-level task | Decomposition per rules below |
| **1** | First recursion | Standard decomposition |
| **2** | Second recursion (terminal) | Forced delegation directly to `@player` — no further splitting |

## 📏 Task Decomposition Rules

| Complexity | Depth < 2 | Depth == 2 |
|---|---|---|
| **Simple** (≤2 concerns) | Delegate directly to `@player` | Delegate to `@player` |
| **Complex** (>2 concerns) | Split into subtasks, delegate each via `@flow` with depth+1 (`@subflow` — same thing, but runs as a subagent) | Force-delegate to `@player` |

## 📂 File Structure

```
agents/
├── AGENTS.md    — DOX contract for agents/ (rules, contracts, Child DOX Index)
├── flow.md      — Orchestrator (primary agent)
├── player.md    — Executor (subagent, minimalist executor)
├── coach.md     — Reviewer (subagent, zero-tolerance reviewer)
└── subflow.md   — Recursive orchestrator (subagent, identical to flow.md except for mode field)
```

## 🎯 Roles: Details

### `@flow` — Orchestrator (primary, temperature 0.1)

- The only top-level interface with the user
- Receives requests, decomposes tasks per depth/concerns rules
- Delegates work exclusively via the `task()` tool
- Evaluates `@coach` verdicts and decides: continue the cycle or move to the next task
- Never answers the user directly — only through the mediation loop

### `@player` — Executor (subagent, temperature 0.6)

- Minimalist executor: minimal code, no explanations
- Does not refactor others' code, does not add validation by default
- Works strictly within the scope of the assigned task
- On linter/test errors — returns the error upward, does not fix

### `@coach` — Reviewer (subagent, temperature 0.2)

- Zero-tolerance checks: security, correctness, anti-patterns, performance
- Checks for AI-generated patterns and security issues
- Returns ACCEPT / REVISE / REJECT with specific feedback
- Does not make code changes — review only

### `@subflow` — Recursive Orchestrator (subagent, temperature 0.1)

- Identical to `@flow`, but runs as a subagent
- Used for complex tasks with >2 concerns at depth < 2
- Each recursion level increases depth by +1

## 📊 Example Task Flow

```
User: "@flow: implement a REST API for user CRUD"
       │
       ▼
@flow (depth=0, complex → split)
       ├── Task 1: "create User model and validation schema" → @flow(depth=1)
       │                    │
       │                    ▼
       │              @player → code → @coach → ACCEPT
       │
       └── Task 2: "create endpoints GET/POST/PUT/DELETE /users" → @flow(depth=1)
                            │
                            ▼
                      @player → code → @coach → REVISE (security issue)
                            │
                            ▼
                      @player (with revision instructions) → revised code → @coach → ACCEPT

@flow collects results from all subtasks and requests a final merged review from @coach
```

## ⚠️ Important Rules

- **`@flow` never answers directly** — only through the mediation loop
- **`@player` does not explain itself** — code speaks for itself
- **`@coach` is uncompromising** — security and correctness over speed
- **Depth 2 is terminal** — at depth 2, tasks are not split further but delegated directly to `@player`

---

## 📖 Related Documents

- [`agents/AGENTS.md`](agents/AGENTS.md) — DOX contract: rules, contracts, Child DOX Index
