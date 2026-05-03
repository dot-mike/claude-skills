# Writing Agent Briefs

An agent brief is a structured comment posted on a GitHub issue when it moves to `ready-for-agent`. It is the authoritative specification the AFK agent works from. The original issue and discussion are context — the agent brief is the contract.

## Principles

### Durability over precision

The issue may sit in `ready-for-agent` for days or weeks. The codebase will change. Write the brief so it stays useful even as files are renamed or refactored.

- **Do** describe interfaces, types, and behavioral contracts
- **Do** name specific types, function signatures, or config shapes the agent should look for
- **Don't** reference file paths — they go stale
- **Don't** reference line numbers
- **Don't** assume the current implementation structure will remain

### Behavioral, not procedural

Describe **what** the system should do, not **how** to implement it.

- **Good:** "The `SkillConfig` type should accept an optional `schedule` field"
- **Bad:** "Open src/types/skill.ts and add a schedule field on line 42"

### Complete acceptance criteria

Every agent brief needs concrete, independently verifiable acceptance criteria.

- **Good:** "Running `gh issue list --label needs-triage` returns only unclassified issues"
- **Bad:** "Triage should work correctly"

### Explicit scope boundaries

State what is out of scope to prevent gold-plating.

## Template

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** one-line description of what needs to happen

**Current behavior:**
What happens now. For bugs: the broken behavior. For enhancements: the status quo.

**Desired behavior:**
What should happen after the agent's work. Include edge cases and error conditions.

**Key interfaces:**
- `TypeName` — what needs to change and why
- `functionName()` — current vs desired return type
- Config shape — any new configuration options

**Acceptance criteria:**
- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2
- [ ] Specific, testable criterion 3

**Out of scope:**
- Thing that should NOT be changed
- Adjacent feature that seems related but is separate
```
