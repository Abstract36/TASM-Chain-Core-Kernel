# TASM-Chain: Glossary

A comprehensive reference of terms and concepts used in TASM-Chain documentation.

---

## Core Concepts

### Possibility Space (Π)
The set of all states that remain possible at a given time, subject to accumulated constraints.

**Notation:** `Π(t)` where `t` is the time index.

**Property:** Monotonically decreasing: `Π(t+1) ⊆ Π(t)`

**Example:**
```
Π(0) = { all possible account balances }
Π(1) = { balances where Alice = 100 }
Π(2) = { balances where Alice = 100 AND Bob = 50 }
```

---

### Universal Possibility Space (𝕌)
The complete set of all conceivable states, before any constraints are applied.

**Initial Condition:** `Π(0) = 𝕌`

**Interpretation:** At genesis, everything is possible.

---

### Elimination Function (ε)
The set of possibilities that have been ruled out by time `t`.

**Definition:** `ε(t) = 𝕌 ∖ Π(t)`

**Property:** Monotonically increasing: `ε(t) ⊆ ε(t+1)`

**Invariant:** `Π(t) ∪ ε(t) = 𝕌` (possibilities are either active or eliminated)

---

### Constraint
A predicate that possibilities must satisfy to remain in the possibility space.

**Types:**
- **Balance constraint:** `balance(account) ≥ amount`
- **Nonce constraint:** `nonce(account) = value`
- **Signature constraint:** `valid_signature(tx, pubkey)`
- **Temporal constraint:** `timestamp ≥ value`
- **Custom constraint:** User-defined predicate

**Effect:** Adding a constraint eliminates possibilities that don't satisfy it.

---

### State
The observable configuration of the system at a given time, derived from the possibility space.

**Definition:** `State(t) = μ(Π(t))` where `μ` is a reduction function.

**Key Insight:** State is *emergent* from possibilities, not *constructed* by transformations.

---

### Reduction Function (μ)
A function that maps a possibility space to a single observable state.

**Signature:** `μ : 𝒫(𝕌) → 𝕌`

**Examples:**
- **Canonical:** Select the lexicographically first state
- **Random:** Select randomly (non-deterministic)
- **Consensus:** Select by validator majority vote
- **Hash-based:** Deterministic pseudorandom selection

**Requirement:** `μ(Π)` must be an element of `Π` (the reduction must select a possible state).

---

### Transition Operator (T)
The function that updates the possibility space based on an event.

**Signature:** `T : 𝒫(𝕌) × Event → 𝒫(𝕌)`

**Definition:** `Π(t+1) = T(Π(t), e(t))`

**Constraint:** `T(Π, e) ⊆ Π` (transitions only eliminate, never create)

---

### Event
An occurrence that triggers a possibility space transition.

**Types:**
- **Transaction:** User-initiated action
- **Block:** Consensus finalization
- **Consensus:** Validator vote
- **Timeout:** Time-based trigger

**Effect:** Generates constraints that filter the possibility space.

---

## Mathematical Notation

### Set Operations

| Symbol | Meaning | Example |
|--------|---------|---------|
| `∈` | Element of | `x ∈ S` (x is in set S) |
| `⊆` | Subset | `A ⊆ B` (A is a subset of B) |
| `⊂` | Proper subset | `A ⊂ B` (A is a strict subset of B) |
| `∪` | Union | `A ∪ B` (elements in A or B) |
| `∩` | Intersection | `A ∩ B` (elements in both A and B) |
| `∖` | Set difference | `A ∖ B` (elements in A but not in B) |
| `∅` | Empty set | `Π = ∅` (no possibilities remain) |
| `𝒫(S)` | Power set | All subsets of S |

### Common Variables

| Symbol | Meaning |
|--------|---------|
| `t` | Time index (discrete) |
| `Π(t)` | Possibility space at time t |
| `ε(t)` | Eliminated possibilities at time t |
| `𝕌` | Universal possibility space |
| `μ` | Reduction function |
| `T` | Transition operator |
| `e(t)` | Event at time t |

---

## Key Properties

### Monotonic Decrease
**Definition:** The possibility space can only shrink over time.

**Formal:** `∀t : Π(t+1) ⊆ Π(t)`

**Implication:** Information is never created, only destroyed.

---

### Monotonic Increase (Eliminations)
**Definition:** Once eliminated, a possibility stays eliminated.

**Formal:** `∀t : ε(t) ⊆ ε(t+1)`

**Implication:** Time is irreversible.

---

### Possibility Conservation
**Definition:** Every possibility is either active or eliminated, never lost.

**Formal:** `Π(t) ∪ ε(t) = 𝕌`

**Implication:** The total "amount" of possibility is conserved.

---

### Irreversibility
**Definition:** Strict elimination cannot be undone.

**Formal:** If `Π(t+1) ⊂ Π(t)` (strict subset), then `∀t' > t+1 : Π(t') ≠ Π(t)`

**Implication:** Possibility collapse is permanent (without external intervention).

---

## Comparison to Traditional Concepts

### Traditional: State Transformation
```
State(t+1) = Apply(State(t), Transaction)
```

**Focus:** How state *changes*

**Mechanism:** Active transformation

---

### TASM: Possibility Elimination
```
Π(t+1) = Π(t) ∖ Eliminated(t)
State(t) = μ(Π(t))
```

**Focus:** What *remains possible*

**Mechanism:** Passive filtering

---

### Equivalence
Both models can represent the same systems, but offer different perspectives:

- **Traditional:** Constructive, forward-looking
- **TASM:** Reductive, backward-eliminating

---

## Advanced Concepts

### Entropy
A measure of uncertainty or randomness in the possibility space.

**Definition:** `H(Π) = -∑ p(s) log p(s)` for `s ∈ Π`

**Interpretation:** 
- High entropy → Many possibilities remain
- Low entropy → Few possibilities remain
- Zero entropy → Exactly one possibility remains

**Property:** Entropy decreases over time (second law of thermodynamics analogy).

---

### Contradiction
A state where no possibilities remain.

**Definition:** `Π(t) = ∅`

**Cause:** Incompatible constraints

**Example:**
```
Constraint 1: Alice ≥ 100
Constraint 2: Alice ≤ 50
Result: No state satisfies both → Π = ∅
```

**Handling:** Reject constraint, rollback, or fork chain.

---

### Chain Fork
A divergence in possibility elimination between two consensus groups.

**Definition:** 
```
Π_A(t) ≠ Π_B(t)
```

**Cause:** Different validators eliminate different possibilities.

**Resolution:**
- **Merge:** Find `Π_merged = Π_A ∩ Π_B` (if non-empty)
- **Split:** Maintain separate chains indefinitely

---

### Consensus
The mechanism by which validators agree on which possibilities to eliminate.

**Traditional:** "Which state transition do we accept?"

**TASM:** "Which possibilities do we rule out?"

**Outcome:** Narrowed possibility space reflecting collective agreement.

---

### Observation
The act of reducing a possibility space to a single state.

**Quantum Analogy:** Wave function collapse

**TASM Analogy:** State emergence from possibilities

**Mechanism:** Apply reduction function `μ`

---

## Practical Terminology

### Constraint Satisfaction
Checking whether a state satisfies all active constraints.

**Function:** `satisfies(state, constraint) → boolean`

**Usage:** Determine if `state ∈ Π(t)`

---

### Constraint Compatibility
Checking whether two constraints can both be satisfied.

**Function:** `compatible(c1, c2) → boolean`

**Usage:** Prevent contradictions before they occur.

---

### State Proof
Evidence that an observed state is valid under all constraints.

**Contains:**
- List of all constraints
- Proof that state satisfies each constraint
- Cryptographic commitments (e.g., Merkle proofs)

---

### Possibility Enumeration
Listing all states in a possibility space.

**Challenge:** Often infeasible (exponential or infinite size)

**Solution:** Lazy evaluation, constraint satisfaction solvers

---

## Philosophical Terms

### Constructive vs. Eliminative
- **Constructive:** Building something new from components
- **Eliminative:** Revealing what remains after removing impossibilities

TASM-Chain is *eliminative*.

---

### Actuality vs. Potentiality
- **Potentiality:** What *could* be (possibility space)
- **Actuality:** What *is* (observed state)

Traditional blockchains focus on actuality; TASM-Chain models both.

---

### Observer Dependence
The idea that different observers may see different states if they use different reduction functions.

**Analogy:** Quantum mechanics (measurement problem)

**TASM:** Deterministic reduction → Observer independence

---

## Acronyms and Abbreviations

| Term | Full Name |
|------|-----------|
| TASM | (Not an acronym; stylized name) |
| Π | Pi (possibility space) |
| ε | Epsilon (elimination function) |
| μ | Mu (reduction function) |
| 𝕌 | Double-struck U (universal space) |
| SAT | Boolean satisfiability |
| 𝒫 | Power set (script P) |

---

## Summary Table

| Traditional Blockchain | TASM-Chain Equivalent |
|------------------------|------------------------|
| State transformation | Possibility elimination |
| Transaction | Event (constraint generator) |
| Consensus on state | Consensus on eliminations |
| State | Observation (reduced possibility space) |
| Fork | Divergent eliminations |
| Merge | Intersection of possibility spaces |
| Irreversibility | Monotonic decrease of Π(t) |

---

## Key Equations

### Fundamental Relation
```
State(t) = μ(Π(t))
Π(t) = 𝕌 ∖ ε(t)
```

### Transition
```
Π(t+1) = T(Π(t), e(t)) = Π(t) ∖ Eliminated(e(t))
```

### Conservation
```
Π(t) ∪ ε(t) = 𝕌
```

### Monotonicity
```
Π(t+1) ⊆ Π(t)
ε(t) ⊆ ε(t+1)
```

---

## Conclusion

This glossary provides a reference for understanding TASM-Chain concepts. For deeper exploration:

- **Theory:** [docs/theory.md](./theory.md)
- **Formalism:** [docs/formal-model.md](./formal-model.md)
- **Implementation:** [docs/kernel-spec.md](./kernel-spec.md)
- **Examples:** [docs/examples.md](./examples.md)

**Remember:** State changes because possibilities disappear over time.
