# Agents — Orchestrated Agent System

## Purpose

A mediated multi-agent system where an orchestrator (`@flow`) decomposes tasks and delegates to specialized agents: `@player` (executor), `@coach` (reviewer), and `@subflow` (recursive delegation for complex tasks). All communication flows through the orchestrator.

## Ownership

- **`@flow`** — primary orchestrator, receives all user requests
- **`@subflow`** — recursive sub-agent with identical logic to flow but runs as a child context (`mode: subagent`)
- **`@player`** — executor; writes minimal code per task instructions
- **`@coach`** — deterministic reviewer (temperature=0.2) that evaluates player output

All agents are `mode: subagent` except `flow`, which is `mode: primary`. Each agent file defines its own permissions, temperature, and rules in front-matter.

## Local Contracts

### Delegation architecture

The orchestrator mediates all communication between user and agents. Agents never interact directly with each other or the user — only through orchestration calls via the Task tool.

**Exception:** flow.md embeds compact role definitions for @player and @coach (lines 83–119) as a convenience so that delegated sub-agents understand their contract when spawned from this file. This is intentional, not cross-referencing — it avoids circular doc dependencies.

### flow.md ↔ subflow.md duplication

`subflow.md` body content is byte-identical to `flow.md`. OpenCode requires separate files because the `mode` field (primary vs subagent) is a per-file front-matter attribute that cannot be shared across files. This is not redundant documentation — it is required by the tooling. Subflow delegates identically but runs in a child context with incrementing depth.

### Ecosystem boundaries

This system is **open**: agents may reach outside the system for information or execution (player has `webfetch: allow`). Internal boundaries exist — orchestrator mediates all inter-agent communication — but there is no enforced isolation.

## Work Guidance

### Depth mechanisms — each agent, separately

**flow / subflow:** use the `depth` parameter for recursive task decomposition:

- Top-level call from user → `depth: 0`
- First recursive delegation → `depth: 1`
- Second recursive delegation → `depth: 2` (terminal; force-delegate to @player, no further splitting)
- Decision tree: complex tasks with `depth < 2` split into subtasks delegated via the same flow agent with `depth + 1`. At `depth == 2`, always delegate directly to player.

**player / coach:** use recursion depth for self-calls via the Task tool, not a shared `depth` parameter:

- **Player max depth:** 2 levels (`caller → @player depth 1 → @player depth 2 → STOP`). Delegate only when subtasks are independent and >30 lines or touch separate modules. If describable in one sentence — do it inline.
- **Coach max depth:** 2 levels. Depth is communicated by the orchestrator via task description, not self-managed by coach (depth 1 → depth 2 → STOP). Allowed only for splitting a single large diff by concern (security, logic, tests, architecture). Each sub-review is independent; no shared state.

### Critical operational rules

**Orchestrator (@flow / @subflow):**

- Every response MUST begin with `🎯 Orchestrator:` prefix — this is the only valid delegation or decision format. No exceptions.
- **Never answer directly, write code, explain solutions, explore files, or perform execution.** The orchestrator's sole output is delegation and review decisions.
- Always delegate to @player for implementation and @coach for review — never do work yourself.

**Player (@player):**

- `webfetch: allow` — permitted for external lookups when needed.
- **Broken linters/tests:** if your change causes lint errors or test failures in unrelated code, stop and return upward immediately (`⚠️ lint failed in utils.py — returning upward`). Do NOT fix them. Do NOT refactor to make them pass. Do NOT touch files outside the task scope.
- Write less code; don't explain; zero scope creep; check before writing with `@explore`.

**Coach (@coach):**

- Reviews git diffs, detects AI-generated code fingerprints, checks all vulnerability categories (injection, auth bypass, SSRF, path traversal, crypto, deserialization), enforces necessity justification for any new code.
- **Depth tracking mandatory:** Every delegated call MUST include current depth in task description using `(depth: N)` format. Max depth: 2 (depth 1 → depth 2 → STOP). Rule of thumb: if sub-task fits in one sentence, review inline — no recursion.

### Workflow loop (mediated cycle)

The orchestrator controls a repeating delegation cycle:

1. **Orchestrator** receives request → decomposes if needed → delegates to `@player`
2. **`@player`** executes and returns result
3. **Orchestrator** passes result to `@coach` for review
4. **`@coach`** responds:
   - ✅ Accepted — orchestrator moves to next task
   - ❌ Rejected — orchestrator sends `@player` a revision task with specific coach feedback
5. Repeat steps 2–4 until the task is fully complete

The orchestrator mediates every step of this cycle. This is not unidirectional delegation — it is a mediated loop where the orchestrator gates transitions between player work and coach review.

## Verification

## Child DOX Index

- `coach.md` — Zero-tolerance reviewer: git diff analysis, AI-code detection, vulnerability checks, anti-patterns, test scrutiny
- `flow.md` — Primary orchestrator: task decomposition, mediated delegation loop to @player/@coach, recursive via @subflow with depth tracking
- `player.md` — Lazy executor: minimal code, scope discipline, webfetch permitted, broken linters/tests → return upward
- `subflow.md` — Identical to flow.md but with `mode: subagent`; required separately by OpenCode for distinct mode metadata
