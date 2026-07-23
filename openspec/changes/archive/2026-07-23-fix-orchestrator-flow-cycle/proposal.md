## Why

The orchestrator flow (`@flow` / `@subflow`) has several behavioral defects that undermine the mediated workflow cycle: it delegates context-gathering to the wrong agent (`@player` instead of `@explore`), passes raw CLI commands as tasks instead of aggregating scope, sometimes routes review work to `@player` instead of `@coach`, duplicates requests in recursive calls instead of splitting them, skips `@coach` review after recursion, and lets `@coach` give conditional approval that shortcuts the cycle. These issues waste tokens, produce lower-quality output, and break the core mediated-loop contract.

## What Changes

- **Context delegation**: Flow must call `@explore` (OpenCode) / `Explore` (Claude) directly when it needs project context, not delegate to `@player` who then calls explore internally
- **Scope aggregation**: Flow must aggregate task scope into a single coherent prompt instead of passing individual CLI commands as separate tasks
- **Review routing**: Flow must always route review to `@coach` — never to `@player`
- **Recursive splitting**: Recursive calls (`@subflow` / self-recursion) must split the request into smaller independent subtasks, not pass the full request through unchanged
- **Post-recursion review**: Flow must invoke `@coach` after each recursion level completes, before merging results
- **Coach fresh review**: `@coach` must review from scratch every time — no conditional approval patterns ("if you fix X, Y, Z you'll get approval")
- **Cycle priority**: Flow must follow the mediated workflow cycle (decompose → player → coach → repeat) unconditionally, regardless of task type or perceived simplicity

## Capabilities

### New Capabilities

- `context-delegation`: Rules for when and how flow delegates context-gathering to `@explore` / `Explore` instead of `@player`
- `scope-aggregation`: Rules for aggregating task scope into coherent prompts instead of passing raw CLI commands
- `review-routing`: Rules ensuring all review work goes to `@coach`, never to `@player`
- `recursive-splitting`: Rules for how recursive calls must split requests into smaller independent subtasks
- `post-recursion-review`: Rules requiring `@coach` review after each recursion level
- `coach-fresh-review`: Rules prohibiting conditional approval patterns in `@coach`
- `cycle-priority`: Rules enforcing the mediated workflow cycle as unconditional priority

### Modified Capabilities

*(None — all capabilities are new)*

## Impact

- **`.opencode/agents/flow.md`**: Major rewrite of delegation logic, context-gathering rules, recursion behavior, and cycle enforcement
- **`.opencode/agents/subflow.md`**: Mirror changes from flow.md (byte-identical body)
- **`.opencode/agents/player.md`**: Minor — remove context-gathering responsibilities, clarify scope boundaries
- **`.opencode/agents/coach.md`**: Minor — add prohibition on conditional approval patterns, enforce fresh-review rule
- **`.claude/agents/flow.md`**: Mirror changes from OpenCode port (Claude port)
- **`.claude/agents/player.md`**: Mirror changes from OpenCode port
- **`.claude/agents/coach.md`**: Mirror changes from OpenCode port
- **`.opencode/AGENTS.md`**: Update Work Guidance and Local Contracts sections
- **`.claude/AGENTS.md`**: Update divergences list if needed
- **Root `AGENTS.md`**: Update if workflow rules change at project level
