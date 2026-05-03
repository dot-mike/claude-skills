---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", wants integration tests, or asks for test-first development. Run ralph first for domain vocabulary and ADR context.
---

# Test-Driven Development

## Philosophy

Tests verify behavior through public interfaces, not implementation. Code changes; tests shouldn't.

**Good tests**: integration-style, through public APIs, describe *what* not *how*. Survive refactors.  
**Bad tests**: mock internal collaborators, test private methods, break on rename without behavior change.

See [tests.md](tests.md) and [mocking.md](mocking.md).

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all code.** Tests written in bulk test imagined behavior, not actual behavior.

```
WRONG: RED(test1,test2,test3...) → GREEN(impl1,impl2,impl3...)
RIGHT: RED→GREEN, RED→GREEN, RED→GREEN  (one at a time)
```

## Workflow

### 1. Planning

Read ralph context before writing anything:

```bash
cat CONTEXT.md 2>/dev/null          # domain vocabulary
cat docs/adr/*.md 2>/dev/null       # past architectural decisions
cat docs/agents/domain.md 2>/dev/null
```

Use domain vocabulary in test names and interface design. Respect ADRs — flag conflicts before proceeding.

- [ ] Confirm interface changes with user
- [ ] Confirm which behaviors to test (prioritize)
- [ ] Identify [deep module](deep-modules.md) opportunities
- [ ] Design interfaces for [testability](interface-design.md)
- [ ] List behaviors to test (not implementation steps)
- [ ] Get user approval

> Missing CONTEXT.md: run `/ralph` first for domain vocabulary.

### 2. Tracer Bullet

Write ONE test → ONE behavior → fails → minimal code → passes.

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

One test at a time. No anticipating future tests. Behavior only.

### 4. Refactor

After all GREEN, see [refactoring.md](refactoring.md). Never refactor while RED.

## Checklist Per Cycle

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```