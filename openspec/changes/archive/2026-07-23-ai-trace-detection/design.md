## Context

The `@coach` agent performs code review on diffs produced by `@player`. Currently, coach reviews all code with uniform scrutiny — it has no mechanism to detect whether code was AI-generated and adjust review depth accordingly. The PRD (`.opencode/plans/PRD.md`) defines a taxonomy of 5 AI-trace categories (Signatures, Naming, Structure, Logic, Context) with a decision matrix that produces CLEAN / SUSPECTED / CONFIRMED verdicts.

The coach agent is defined in `agents/coach.md` (OpenCode reference) and `/.claude/agents/coach.md` (Claude Code port). Both ports must be updated. Detection is rule-based — no ML models or external APIs.

## Scope

The PRD defines 28 AI-trace markers across 5 categories. Below is the full list with in-scope/deferred/excluded status and rationale.

### A-Category: Signatures (7 markers)
| Marker | Name | Status | Rationale |
|--------|------|--------|-----------|
| A1 | Instruction step comments | In-scope | Easy grep pattern, high signal |
| A2 | Placeholder comments | In-scope | Easy grep pattern, high signal |
| A3 | Narrative comments | In-scope | Easy grep pattern, high signal |
| A4 | Universal docstrings on trivial functions | In-scope | Heuristic check, medium signal |
| A5 | AI-formatted commit messages | In-scope | Lower priority — commit analysis is separate from diff review |
| A6 | AI-formatted PR descriptions | In-scope | Lower priority — PR description analysis is separate from diff review |
| A7 | Explicit AI references | In-scope | Easy grep pattern, high signal |

### B-Category: Naming (5 markers)
| Marker | Name | Status | Rationale |
|--------|------|--------|-----------|
| B1 | Overly long identifiers, no abbreviations | In-scope | Heuristic check, medium signal |
| B2 | Zero abbreviations in entire diff | In-scope | Heuristic check, low signal alone |
| B3 | Academic verb usage | In-scope | Pattern match, low signal |
| B4 | Uniform naming patterns | In-scope | Pattern match, low signal |
| B5 | No domain-specific names | In-scope | Heuristic check, medium signal |

### C-Category: Structure (6 markers)
| Marker | Name | Status | Rationale |
|--------|------|--------|-----------|
| C1 | CRUD symmetry | In-scope | Logic analysis, medium signal |
| C2 | Universal error handling | In-scope | Pattern match, medium signal |
| C3 | Unnecessary abstractions | In-scope | Logic analysis, medium signal |
| C4 | Textbook file ordering | **Deferred** | Too common in human code too — low signal-to-noise ratio |
| C5 | Universal documentation | In-scope | Heuristic check, medium signal |
| C6 | Dead code | **Deferred** | Requires compiler-level analysis — impractical for rule-based detection |

### D-Category: Logic (5 markers)
| Marker | Name | Status | Rationale |
|--------|------|--------|-----------|
| D1 | Reimplemented built-ins | In-scope | Pattern match, high signal |
| D2 | Custom library code | In-scope | Requires @explore, high signal |
| D3 | Over-validation | **Deferred** | Requires type system understanding — impractical for rule-based detection |
| D4 | Wrong abstraction level | **Deferred** | Subjective judgment — impractical for rule-based detection |
| D5 | No project idioms | In-scope | Requires @explore, medium signal |

### E-Category: Context (5 markers)
| Marker | Name | Status | Rationale |
|--------|------|--------|-----------|
| E1 | Duplicate utility creation | In-scope | Requires @explore, high signal |
| E2 | New file instead of edit | In-scope | Requires @explore, medium signal |
| E3 | Duplicate dependency | In-scope | Requires @explore, high signal |
| E4 | Style mismatch | In-scope | Requires @explore, medium signal |
| E5 | Wrong import style | In-scope | Requires @explore, medium signal |

## Goals / Non-Goals

**Goals:**
- Add AI-trace detection as a preliminary phase in the coach review workflow
- Implement detection for all 5 categories: Signatures (A), Naming (B), Structure (C), Logic (D), Context (E)
- Implement the decision matrix from the PRD (Section 4) for verdict computation
- Add structured `## AI Detection` section to coach review output
- Support Context-category checks via `@explore` delegation
- Update both OpenCode and Claude Code coach agent files

**Non-Goals:**
- ML-based detection or probabilistic models
- Automated rejection or blocking of AI-generated code
- Per-project or per-author baseline learning (future direction)
- Detection in non-diff contexts (e.g., full codebase audit)
- Language-specific detection tuning (initial release is language-agnostic)

## Decisions

### Decision 1: Rule-based detection over ML
- **Chosen**: Pattern-matching rules and heuristics for all 5 categories
- **Alternatives considered**: ML classifier trained on AI vs human code
- **Rationale**: Rule-based is deterministic, explainable, zero external dependencies, and immediately deployable. ML would require training data, model maintenance, and introduces opacity in review output. The PRD taxonomy is already structured as explicit rules — implementing as code is straightforward.

### Decision 2: Detection as coach-internal logic, not separate module
- **Chosen**: Detection logic lives inside the coach agent instructions/rules
- **Alternatives considered**: Separate `ai-detector` subagent or external script
- **Rationale**: The detection is tightly coupled to review workflow — it runs before review, and its output feeds into review scrutiny level. A separate module would add delegation overhead. Coach already has the diff context. For complex E-category checks, coach delegates to `@explore` directly.

### Decision 3: Detection order (A → B → C → D → E)
- **Chosen**: Run categories in order of detection cost (cheapest first)
- **Rationale**: A-category (grep signatures) is O(n) and immediate. B and C are moderate. D requires logic analysis. E requires `@explore` delegation (most expensive). If overall verdict is CLEAN after A-D, skip E entirely.

### Decision 4: Reporting as structured markdown section
- **Chosen**: Add `## AI Detection` section to coach review output with verdict, evidence list, and action request
- **Rationale**: Consistent with existing coach output format. Structured enough for parsing, readable by humans. No new output format to maintain.

### Decision 5: Per-category verdict computation
- **Chosen**: Each category produces a verdict (CLEAN / SUSPECTED / CONFIRMED) based on its markers, then the decision matrix combines category verdicts into an overall verdict
- **Rules**:
  - **CLEAN**: 0-1 markers detected in the category, none with HIGH weight
  - **SUSPECTED**: 2+ LOW/MED markers detected, OR exactly 1 HIGH marker
  - **CONFIRMED**: 3+ HIGH markers detected in the category, OR category-specific threshold met
- **Rationale**: Per-category verdicts allow the decision matrix to work with abstracted category signals rather than raw marker counts. This makes the matrix stable as markers are added/removed.

## Risks / Trade-offs

- **[False positives]** Professional human code may trigger SUSPECTED (e.g., clean code with consistent naming). **Mitigation**: PRD Section 5.3 explicitly excludes professional behaviors from detection. Thresholds are conservative (≥3 A-hits for CONFIRMED).
- **[Performance]** E-category checks require `@explore` delegation, adding latency. **Mitigation**: E-checks are only run when other categories already indicate SUSPECTED. Early termination avoids unnecessary work.
- **[Port divergence]** OpenCode and Claude Code coach files may drift. **Mitigation**: Both files updated in the same change. Port Synchronization rules in root AGENTS.md require same-commit updates.
- **[Maintenance]** Detection rules may need tuning as AI output patterns evolve. **Mitigation**: Rules are centralized in coach agent instructions — single point of update. Thresholds are explicit constants, easy to adjust.
- **[Impractical markers]** Markers C4 (textbook ordering), C6 (dead code), D3 (over-validation), and D4 (abstraction level) are deferred because they are impractical to implement as deterministic rules — they require compiler-level analysis, type system understanding, or subjective judgment. **Mitigation**: These markers are explicitly excluded from scope with documented rationale. If implementation reveals other markers are impractical, they will be deferred in the same way.
- **[Coach.md bloat]** Adding detection rules to coach.md could make the file excessively long. **Mitigation**: Detection rules are structured as a separate section within coach.md (e.g., `## AI-Trace Detection Rules`), not interleaved with existing review rules. This keeps the file organized and allows easy updates.
