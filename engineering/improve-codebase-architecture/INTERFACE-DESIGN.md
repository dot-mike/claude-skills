# Interface Design

When the user wants to explore alternative interfaces for a chosen deepening candidate. Based on "Design It Twice" (Ousterhout) — your first idea is unlikely to be the best.

Uses vocabulary from [LANGUAGE.md](LANGUAGE.md) and [DEEPENING.md](DEEPENING.md).

## Process

### 1. Frame the problem space

Write a user-facing explanation before spawning sub-agents:

- Constraints any new interface must satisfy
- Dependencies and their category (see [DEEPENING.md](DEEPENING.md))
- A rough illustrative code sketch to make constraints concrete — not a proposal

Show this to the user, then proceed immediately to Step 2.

### 2. Spawn sub-agents in parallel

Spawn 3+ sub-agents using the Agent tool, each producing a **radically different** interface. Brief each independently (file paths, coupling details, dependency category). Give each a different design constraint:

- Agent 1: "Minimize the interface — aim for 1–3 entry points max. Maximise leverage per entry point."
- Agent 2: "Maximise flexibility — support many use cases and extension."
- Agent 3: "Optimise for the most common caller — make the default case trivial."
- Agent 4 (if applicable): "Design around ports & adapters for cross-seam dependencies."

Include both [LANGUAGE.md](LANGUAGE.md) vocabulary and CONTEXT.md vocabulary in each brief.

Each sub-agent outputs:

1. Interface (types, methods, params — plus invariants, ordering, error modes)
2. Usage example showing how callers use it
3. What the implementation hides behind the seam
4. Dependency strategy and adapters
5. Trade-offs — where leverage is high, where it's thin

### 3. Present and compare

Present designs sequentially, then compare in prose. Contrast by **depth** (leverage at the interface), **locality** (where change concentrates), and **seam placement**.

Give your own recommendation: which is strongest and why. If elements from different designs combine well, propose a hybrid. Be opinionated.