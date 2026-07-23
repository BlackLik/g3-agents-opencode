## Context

The orchestrator flow (`@flow` / `@subflow`) is the central mediator in a multi-agent system. It decomposes user requests, delegates to `@player` for execution, and passes results to `@coach` for review. The current implementation has seven behavioral defects that undermine this cycle:

1. **Context delegation**: Flow delegates context-gathering to `@player`, who then calls `@explore` internally — adding an unnecessary hop that wastes tokens and obscures the delegation chain.
2. **Scope aggregation**: Flow passes individual CLI commands as separate tasks instead of aggregating them into a coherent scope — causing excessive token usage and fragmented context.
3. **Review routing**: Flow sometimes delegates review work to `@player` instead of `@coach` — breaking the separation of concerns between execution and review.
4. **Recursive splitting**: Recursive calls (`@subflow` / self-recursion) pass the full request unchanged instead of splitting it into smaller independent subtasks — defeating the purpose of recursion.
5. **Post-recursion review**: Flow skips `@coach` review after recursion completes — leaving merged results unreviewed.
6. **Coach fresh review**: `@coach` uses conditional approval patterns ("if you fix X, Y, Z you'll get approval") that shortcut the cycle and reduce review quality.
7. **Cycle priority**: Flow sometimes bypasses the mediated cycle for "simple" tasks — answering directly or delegating without review.

## Goals / Non-Goals

**Goals:**
- Flow always delegates context-gathering to `@explore` (OpenCode) / `Explore` (Claude) directly — never to `@player`
- Flow aggregates task scope into coherent prompts instead of passing raw CLI commands
- Flow always routes review to `@coach` — never to `@player`
- Recursive calls split requests into smaller independent subtasks with clear boundaries
- Flow invokes `@coach` after each recursion level completes
- `@coach` reviews from scratch every time — no conditional approval patterns
- Flow follows the mediated workflow cycle unconditionally for all tasks

**Non-Goals:**
- Changing the underlying agent infrastructure or tooling
- Adding new agent roles beyond flow, player, coach, subflow, explore
- Changing the player or coach internal logic beyond the specific fixes listed
- Performance optimization beyond token-waste reduction

## Decisions

### Decision 1: Direct explore delegation
**Choice**: Flow calls `@explore` (OpenCode) / `Explore` (Claude) directly via `subagent_type="explore"` when it needs project context.
**Rationale**: Removes the unnecessary `@player` middle-hop. Flow currently lacks `task` permission for `explore` in its frontmatter — the frontmatter only allows `player`, `coach`, `subflow`. This change adds `explore: allow` to the frontmatter so flow can delegate context-gathering directly.
**Alternative considered**: Keeping the current pattern (flow → player → explore) — rejected because it wastes tokens and adds latency.

### Decision 2: Scope aggregation via prompt construction
**Choice**: Flow collects all related CLI commands, file reads, and investigation steps into a single coherent prompt before delegating to `@player`.
**Rationale**: A single aggregated prompt gives `@player` full context in one shot, avoiding back-and-forth and reducing token waste from repeated context loading.
**Alternative considered**: Passing commands one by one — rejected as the current broken behavior.

### Decision 3: Strict review routing enforcement
**Choice**: Flow's delegation rules explicitly forbid `subagent_type="player"` for any task containing the words "review", "check", "verify", "audit", or "validate". Such tasks MUST use `subagent_type="coach"`.
**Rationale**: Prevents the common failure mode where flow treats review as a sub-task of execution.
**Alternative considered**: Soft guidance — rejected because the failure occurs repeatedly.

### Decision 4: Recursive split protocol
**Choice**: When flow delegates to `@subflow` (or self-recurses in Claude port), it MUST decompose the request into N independent subtasks and delegate each separately. The prompt MUST NOT contain the full unsplit request.
**Rationale**: The purpose of recursion is to split work into smaller pieces. Passing the full request unchanged defeats this purpose and wastes tokens.
**Alternative considered**: Passing the full request with "split this" instruction — rejected because it shifts the splitting responsibility to the wrong level.

### Decision 5: Post-recursion coach gate
**Choice**: After all subtasks from a recursion level complete, flow MUST call `@coach` to review the merged result before proceeding to the next level or returning to the caller.
**Rationale**: Ensures quality at each recursion boundary. Without this gate, errors in early subtasks propagate unchecked.
**Alternative considered**: Review only at the top level — rejected because errors compound across recursion levels.

### Decision 6: No conditional approval in coach
**Choice**: `@coach` MUST issue a binary verdict (✅ Accepted or ❌ Rejected) with specific findings. Conditional patterns like "if you fix X, Y, Z you'll get approval" are prohibited. If rejected, flow creates a new revision task with the findings — coach does not prescribe the fix.
**Rationale**: Conditional approval creates false confidence and shortcuts the cycle. The orchestrator decides what to do with rejection findings, not the reviewer.
**Alternative considered**: Allowing conditional approval with explicit fix instructions — rejected because it conflates review and execution roles.

### Decision 7: Unconditional cycle enforcement
**Choice**: Flow MUST follow the full mediated cycle (decompose → player → coach → repeat) for EVERY task, regardless of perceived simplicity. No direct answers, no skipping review, no delegating to player without coach follow-up.
**Rationale**: The mediated cycle is the core contract of the system. Bypassing it for "simple" tasks creates inconsistency and quality gaps.
**Alternative considered**: Allowing shortcuts for trivial tasks — rejected because "trivial" is subjective and undermines the system.

## Risks / Trade-offs

- **Increased latency for simple tasks**: Full cycle enforcement adds overhead for trivial changes. Mitigation: The cycle is fast when player output is clean — coach accepts quickly.
- **Explore delegation complexity**: Flow must learn when to call explore vs player. Mitigation: Clear rules — if the task is "read/find/investigate" → explore; if "write/modify/create" → player.
- **Recursive split overhead**: Splitting into subtasks adds planning time. Mitigation: The split happens once at each level; the savings from parallel execution and smaller contexts outweigh the cost.
- **Coach fresh-review cost**: Full re-review at each recursion level duplicates effort. Mitigation: Each level reviews only the subtasks at that level — scope is naturally bounded.
