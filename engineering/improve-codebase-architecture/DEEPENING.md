# Deepening

How to deepen a cluster of shallow modules safely, given its dependencies. Assumes the vocabulary in [LANGUAGE.md](LANGUAGE.md).

## Dependency categories

Classify dependencies before proposing a deepening. The category determines how the deepened module is tested across its seam.

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — merge the modules and test through the new interface directly. No adapter needed.

### 2. Local-substitutable

Dependencies that have local test stand-ins (PGLite for Postgres, in-memory filesystem). Deepenable if the stand-in exists. The deepened module is tested with the stand-in in the test suite. The seam is internal; no port at the external interface.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). Define a **port** (interface) at the seam. The deep module owns the logic; the transport is injected as an **adapter**. Tests use an in-memory adapter; production uses HTTP/gRPC/queue.

Recommendation shape: _"Define a port at the seam, implement an HTTP adapter for production and an in-memory adapter for testing, so the logic sits in one deep module even though it's deployed across a network."_

### 4. True external (Mock)

Third-party services (Stripe, Twilio, etc.). The deepened module takes the dependency as an injected port; tests provide a mock adapter.

## Seam discipline

- **One adapter means a hypothetical seam. Two adapters means a real one.** Don't introduce a port unless at least two adapters are justified (typically production + test).
- **Internal seams vs external seams.** Don't expose internal seams through the interface just because tests use them.

## Testing strategy: replace, don't layer

- Old unit tests on shallow modules become waste once tests at the deepened interface exist — delete them.
- Write new tests at the deepened module's interface. **The interface is the test surface.**
- Tests assert on observable outcomes through the interface, not internal state.
- Tests must survive internal refactors — if a test changes when the implementation changes, it's testing past the interface.