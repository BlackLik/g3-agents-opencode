## 1. Coach Agent Updates

- [x] 1.1 Update `.opencode/agents/coach.md` with AI-trace detection rules, detection workflow, and reporting format
- [x] 1.2 Update `/.claude/agents/coach.md` with identical AI-trace detection rules (port synchronization)
- [x] 1.3 Add AI-trace detection as a preliminary phase in the coach review workflow (run before code review)

## 2. A-Category: Signature Detection

- [x] 2.1 Implement A1 detection: grep for `Step \d` instruction comments in diff
- [x] 2.2 Implement A2 detection: grep for `your logic|your code` placeholder comments
- [x] 2.3 Implement A3 detection: grep for conversational/narrative comment markers
- [x] 2.4 Implement A4 detection: check docstring density on trivial functions (≤5 lines) with structured annotations
- [x] 2.5 Implement A5 detection: detect AI-formatted commit messages (rigid template, no stylistic variation) — included because commit formatting is a strong AI signal
- [x] 2.6 Implement A6 detection: detect AI-formatted PR descriptions (formulaic structure with sections) — included because PR description formatting is a strong AI signal
- [x] 2.7 Implement A7 detection: grep for explicit AI references ("As an AI")

## 3. B-Category: Naming Detection

- [x] 3.1 Implement identifier extraction from diff (function names, variable names, parameter names)
- [x] 3.2 Implement B1 detection: average identifier length >25 chars AND no abbreviations (abbreviation defined as ≤3 chars, non-dictionary words, common shortenings like idx/cfg/msg/buf)
- [x] 3.3 Implement B2 detection: zero abbreviations in entire diff — included because AI tends to avoid abbreviations entirely
- [x] 3.4 Implement B3 detection: flag academic verbs (perform, execute, process, handle, validate)
- [x] 3.5 Implement B4 detection: detect uniform `verbNoun()` naming pattern across all functions
- [x] 3.6 Implement B5 detection: no domain-specific names used — included because AI often misses project-specific terminology

## 4. C-Category: Structure Detection

- [x] 4.1 Implement C1 detection: detect CRUD symmetry (full CRUD when only read needed — heuristic: count call sites, flag if write ops have 0 call sites)
- [x] 4.2 Implement C2 detection: detect universal try/except wrapping on every external call
- [x] 4.3 Implement C3 detection: detect interface/abstract class for single implementation
- [x] 4.4 Implement C5 detection: detect universal docstrings on every function (including trivial getters/setters) — included because AI tends to over-document
- [x] 4.5 Implement per-category verdict computation for C-category: CLEAN (0-1 markers, none HIGH), SUSPECTED (2+ LOW/MED or 1 HIGH), CONFIRMED (3+ HIGH)

> **Note**: C4 (textbook file ordering) and C6 (dead code) are deferred. C4 is too common in human code (low signal-to-noise). C6 requires compiler-level analysis (impractical for rule-based detection). If implementation reveals other C-category markers are impractical, defer them similarly and update design/spec.

## 5. D-Category: Logic Detection

- [x] 5.1 Implement D1 detection: detect manual sort/filter/map replacing built-ins
- [x] 5.2 Implement D2 detection: detect custom HTTP client, retry logic, or ORM when library exists (requires @explore)
- [x] 5.3 Implement D5 detection: detect no project idioms used (generic patterns instead of project conventions, requires @explore) — included because AI often ignores project-specific patterns
- [x] 5.4 Implement per-category verdict computation for D-category: CLEAN (0-1 markers, none HIGH), SUSPECTED (2+ LOW/MED or 1 HIGH), CONFIRMED (3+ HIGH)

> **Note**: D3 (over-validation) and D4 (wrong abstraction level) are deferred. D3 requires type system understanding (impractical for rule-based detection). D4 is subjective judgment (impractical for deterministic rules). If implementation reveals other D-category markers are impractical, defer them similarly and update design/spec.

## 6. E-Category: Context Detection

- [x] 6.1 Implement E1 detection: detect new utility file creation when equivalent exists (requires @explore)
- [x] 6.2 Implement E2 detection: detect new file instead of editing existing one (requires @explore) — included because AI tends to create new files rather than extend existing ones
- [x] 6.3 Implement E3 detection: detect duplicate dependency addition (requires @explore)
- [x] 6.4 Implement E4 detection: detect style mismatch with project conventions (requires @explore) — included because AI often uses generic style
- [x] 6.5 Implement E5 detection: detect wrong import/require style (requires @explore) — included because AI often uses wrong module system
- [x] 6.6 Implement conditional execution: skip E-category if no other category is SUSPECTED or CONFIRMED

## 7. Per-Category Verdict Computation

- [x] 7.1 Implement per-category verdict computation for all 5 categories: each category produces CLEAN (0-1 markers, none HIGH), SUSPECTED (2+ LOW/MED or 1 HIGH), CONFIRMED (3+ HIGH)
- [x] 7.2 Ensure per-category verdicts feed into the decision matrix (not raw marker counts)

## 8. Decision Matrix

- [x] 8.1 Implement verdict computation: combine per-category verdicts into overall verdict
- [x] 8.2 Implement CLEAN verdict: ≤1 SUSPECTED, 0 CONFIRMED → normal review
- [x] 8.3 Implement SUSPECTED verdict: 2-3 SUSPECTED or 1 CONFIRMED → flag with explanation request
- [x] 8.4 Implement CONFIRMED verdict: ≥4 SUSPECTED or ≥2 CONFIRMED → elevate scrutiny

## 9. Reporting Format

- [x] 9.1 Implement `## AI Detection` section in coach review output with verdict
- [x] 9.2 Implement evidence listing: marker ID, description, file:line location
- [x] 9.3 Implement action request text for SUSPECTED and CONFIRMED verdicts
- [x] 9.4 Ensure CLEAN verdict omits the AI Detection section entirely

## 10. Verification

- [x] 10.1 Create test fixture: sample AI-generated diff that triggers markers across all 5 categories (include A1-A7, B1-B5, C1-C3+C5, D1-D2+D5, E1-E5)
- [x] 10.2 Create test fixture: sample human-written diff that should produce CLEAN verdict (professional code with varied naming, no AI signatures, appropriate structure)
- [x] 10.3 Test all 5 categories detect correctly on AI-generated diff fixture
- [x] 10.4 Test false positive rate on human-written diff fixture: acceptance criteria = 0 false positives (CLEAN verdict)
- [x] 10.5 Test detection rate on AI-generated diff fixture: acceptance criteria = ≥80% of in-scope markers detected
- [x] 10.6 Test conditional E-category: skipped when no other category is SUSPECTED
- [x] 10.7 Verify both OpenCode and Claude Code coach files are in sync
- [x] 10.8 If implementation reveals any in-scope marker is impractical to detect as a rule, update design.md (defer it with rationale) and spec.md (remove its scenarios) before continuing

## 11. Artifact Updates

- [x] 11.1 If implementation reveals any in-scope marker is impractical to detect as a deterministic rule, update design.md to defer it with rationale and spec.md to remove its scenarios
- [x] 11.2 Update this task list if any tasks are added, removed, or reordered during implementation
