## Why

The `@coach` agent currently reviews code without awareness of whether it was AI-generated, missing an opportunity to calibrate scrutiny appropriately. AI-generated code exhibits systematic patterns ("AI traces") that differ from human-written code — detecting these allows the coach to apply proportional review rigor. This change adds a structured AI-trace detection capability to the coach review workflow.

## What Changes

- Add AI-trace detection rules integrated into `@coach` agent that analyzes code diffs across 5 categories: Signatures (explicit text markers), Naming (identifier style), Structure (code architecture), Logic (reinvention/over-engineering), Context (project awareness)
- Update both `.opencode/agents/coach.md` (OpenCode reference) and `/.claude/agents/coach.md` (Claude Code port) with identical detection rules
- Implement a decision matrix that produces verdicts: CLEAN, SUSPECTED, or CONFIRMED
- Integrate detection into the coach review workflow as a preliminary analysis phase
- Add structured reporting format for AI detection findings in coach review output
- Add `@explore` delegation support for Context-category checks (project awareness)
- Update coach agent instructions to include AI-trace detection rules

## Capabilities

### New Capabilities
- `ai-trace-detection`: Core detection rule set that analyzes code diffs for AI-generated code patterns across 5 categories (Signatures, Naming, Structure, Logic, Context), applies a weighted decision matrix, and produces structured verdicts with evidence

### Modified Capabilities

None — this is a new capability that does not change existing spec-level requirements.

## Impact

- **Coach agent** (`agents/coach.md` and `/.claude/agents/coach.md`): Updated with AI-trace detection rules for 5 categories (Signatures, Naming, Structure, Logic, Context), decision matrix for verdict computation, detection workflow phase, and structured reporting format
- **Coach review output**: New `## AI Detection` section in review output with verdict and evidence
- **@explore integration**: Context-category checks require delegation to @explore for project-aware analysis
- **No breaking changes**: Existing coach review behavior is preserved; AI detection is additive
- **No new dependencies**: Detection is rule-based (pattern matching, heuristics) — no ML models or external APIs
