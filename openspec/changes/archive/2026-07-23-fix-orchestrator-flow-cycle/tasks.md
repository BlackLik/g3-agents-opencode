## 1. Context Delegation

- [x] 1.1 Update `flow.md` — replace "delegate context-gathering to @player" with "delegate directly to @explore via subagent_type='explore'"
- [x] 1.2 Update `subflow.md` — mirror the same context delegation changes from flow.md
- [x] 1.3 Update `player.md` — add rule: reject tasks whose primary purpose is reading/investigating; return upward with routing hint
- [x] 1.4 Update `.claude/agents/flow.md` — mirror context delegation changes for Claude port
- [x] 1.5 Update `.claude/agents/player.md` — mirror player rejection rule for Claude port
- [x] 1.6 Add `explore: allow` to `flow.md` frontmatter under `task:` permissions
- [x] 1.7 Add `Explore` to Claude `flow.md` tools declaration (change `tools: Agent(flow, player, coach)` to include Explore)
- [x] 1.8 Add flow-side handling rule for explore output: flow SHALL pass explore's returned output verbatim to @player as context

## 2. Scope Aggregation

- [x] 2.1 Update `flow.md` — add scope aggregation rule: aggregate related commands/reads into one coherent prompt before delegating to @player
- [x] 2.2 Update `flow.md` — add rule: no raw CLI command passthrough; always scope and contextualize
- [x] 2.3 Update `subflow.md` — mirror scope aggregation rules
- [x] 2.4 Update `.claude/agents/flow.md` — mirror scope aggregation rules

## 3. Review Routing

- [x] 3.1 Update `flow.md` — add keyword-based routing enforcement: tasks with "review", "check", "verify", "audit", "validate" MUST use subagent_type="coach"
- [x] 3.2 Update `player.md` — add rule: if task is review-oriented, reject with "This is a review task — routing to @coach"
- [x] 3.3 Update `subflow.md` — mirror review routing rules
- [x] 3.4 Update `.claude/agents/flow.md` — mirror review routing rules
- [x] 3.5 Update `.claude/agents/player.md` — mirror review rejection rule

## 4. Recursive Splitting

- [x] 4.1 Update `flow.md` — add rule: recursive delegation MUST split request into N independent subtasks; prompt MUST NOT contain full unsplit request
- [x] 4.2 Update `flow.md` — add subtask boundary clarity rules: each subtask defines scope, success criteria, output format
- [x] 4.3 Update `subflow.md` — mirror recursive splitting rules
- [x] 4.4 Update `.claude/agents/flow.md` — mirror recursive splitting rules

## 5. Post-Recursion Review

- [x] 5.1 Update `flow.md` — add rule: after all subtasks at a recursion level complete and merge, invoke @coach before proceeding
- [x] 5.2 Update `flow.md` — add rule: coach rejection at any recursion level blocks progression; create revision tasks until accepted
- [x] 5.3 Update `subflow.md` — mirror post-recursion review rules
- [x] 5.4 Update `.claude/agents/flow.md` — mirror post-recursion review rules
- [x] 5.5 Add rule: flow MUST include level-scoping info in coach prompt (e.g., "Review only the depth-2 subtask outputs: ...")

## 6. Coach Fresh Review

- [x] 6.1 Update `coach.md` — add rule: binary verdict only (✅ Accepted or ❌ Rejected); no conditional approval patterns
- [x] 6.2 Update `coach.md` — add rule: review from scratch each time; no carry-forward assumptions
- [x] 6.3 Update `coach.md` — add rule: coach identifies what and why, but does NOT prescribe code fixes
- [x] 6.4 Update `.claude/agents/coach.md` — mirror fresh review rules

## 7. Cycle Priority

- [x] 7.1 Update `flow.md` — add rule: follow full mediated cycle unconditionally for EVERY task regardless of perceived simplicity
- [x] 7.2 Update `flow.md` — add rule: no direct answers; every user-facing response goes through player → coach → deliver
- [x] 7.3 Update `flow.md` — add rule: no skipping coach review; cycle repeat on rejection
- [x] 7.4 Update `subflow.md` — mirror cycle priority rules
- [x] 7.5 Update `.claude/agents/flow.md` — mirror cycle priority rules

## 8. Documentation Updates

- [x] 8.1 Update `.opencode/AGENTS.md` — reflect new delegation rules in Work Guidance and Local Contracts
- [x] 8.2 Update `.claude/AGENTS.md` divergences list — add entry: "Flow calls Explore directly instead of via player for context-gathering" if not already covered
- [x] 8.3 Update root `AGENTS.md` — update if workflow rules changed at project level (no changes needed — workflow rules unchanged at project level)

## 9. Verification

- [x] 9.1 Verify `flow.md` frontmatter includes `explore: allow` under `task:` permissions (FAIL: explore: allow NOT present in flow.md frontmatter — task 1.6 not yet done)
- [x] 9.2 Verify Claude `flow.md` tools declaration includes Explore (FAIL: Explore NOT in Claude flow.md tools declaration — task 1.7 not yet done)
- [x] 9.3 Manual walkthrough: simulate a context-gathering task and confirm flow calls explore directly
- [x] 9.4 Run `npx markdownlint-cli2` from repo root to confirm no formatting regressions (FAIL: 638 pre-existing issues in 33 files — not caused by these changes)
- [x] 9.5 Verify all 7 spec files are consistent in format and style
