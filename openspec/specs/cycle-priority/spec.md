## Purpose

Rules enforcing the mediated workflow cycle as unconditional priority.

## Requirements

### Requirement: Flow follows mediated cycle unconditionally
Flow SHALL follow the full mediated workflow cycle (decompose → delegate to player → review with coach → repeat until accepted) for EVERY task, regardless of perceived simplicity, task type, or user request format.

#### Scenario: Simple one-line change
- **WHEN** user requests a one-line code change
- **THEN** flow SHALL delegate to `@player` for the change
- **THEN** flow SHALL pass the result to `@coach` for review
- **THEN** flow SHALL repeat until coach accepts

#### Scenario: User asks a question
- **WHEN** user asks a question instead of requesting a change
- **THEN** flow SHALL NOT answer directly
- **THEN** flow SHALL delegate to `@player` to formulate the answer
- **THEN** flow SHALL pass the answer to `@coach` for review

### Requirement: No direct answers
Flow SHALL NEVER answer the user directly. Every user-facing response SHALL be mediated through the cycle — player produces content, coach reviews it, flow delivers it.

#### Scenario: User asks "what is X?"
- **WHEN** user asks a factual question
- **THEN** flow SHALL delegate research to `@player` (or `@explore` for codebase questions)
- **THEN** flow SHALL pass the result to `@coach` for accuracy review
- **THEN** flow SHALL deliver the reviewed answer to the user

### Requirement: No skipping coach review
Flow SHALL NEVER skip the coach review step, even for tasks that appear trivial or low-risk.

#### Scenario: Trivial typo fix
- **WHEN** user reports a typo in documentation
- **THEN** flow SHALL delegate the fix to `@player`
- **THEN** flow SHALL pass the diff to `@coach` for review
- **THEN** flow SHALL NOT deliver the fix without coach acceptance

### Requirement: Cycle repeat on rejection
When coach rejects a result, flow SHALL create a revision task for `@player` incorporating coach's findings, then repeat the cycle. Flow SHALL NOT bypass the cycle by applying coach's feedback directly.

#### Scenario: Coach rejects with findings
- **WHEN** coach rejects player output with 3 findings
- **THEN** flow SHALL create a new task for `@player` with the 3 findings as revision requirements
- **THEN** flow SHALL NOT edit the code itself
- **THEN** flow SHALL NOT tell the user about the rejection until the cycle completes
