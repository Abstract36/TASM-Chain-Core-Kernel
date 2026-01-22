# TASM-Chain: Formal Model

## Mathematical Formalism

This document provides rigorous mathematical definitions for the TASM-Chain kernel.

---

## Notation

| Symbol | Meaning |
|--------|---------|
| `𝕌` | Universal possibility space |
| `𝒫(S)` | Power set of S |
| `∅` | Empty set |
| `∖` | Set difference |
| `⊆` | Subset relation |
| `∩` | Intersection |
| `∪` | Union |
| `ℕ` | Natural numbers (including 0) |
| `t ∈ ℕ` | Discrete time index |

---

## Definitions

### Definition 1: Universal Possibility Space

Let `𝕌` denote the **universal possibility space**, representing all conceivable blockchain states.

For practical implementations:
```
𝕌 = {all valid state configurations}
```

For theoretical purity:
```
𝕌 = 𝒫(Transactions) × Configurations
```

Where:
- `Transactions` = set of all possible transactions
- `Configurations` = set of all possible system configurations

---

### Definition 2: Possibility Space at Time t

Define `Π(t) ⊆ 𝕌` as the **possibility space at time t**.

**Property (Monotonic Decrease):**
```
∀t ∈ ℕ : Π(t+1) ⊆ Π(t)
```

The possibility space can only decrease (or remain constant) over time.

**Initial Condition:**
```
Π(0) = 𝕌
```

At genesis, all possibilities remain open.

---

### Definition 3: Elimination Function

Define `ε : ℕ → 𝒫(𝕌)` as the **elimination function** at time `t`:

```
ε(t) = 𝕌 ∖ Π(t)
```

`ε(t)` represents all possibilities that have been eliminated by time `t`.

**Property (Monotonic Increase):**
```
∀t ∈ ℕ : ε(t) ⊆ ε(t+1)
```

Once eliminated, a possibility remains eliminated.

---

### Definition 4: State Emergence

The **observed state** at time `t` is:

```
State(t) = μ(Π(t))
```

Where `μ : 𝒫(𝕌) → 𝕌` is a **reduction function** that maps a possibility space to a single representative state.

**Common reduction strategies:**

1. **Canonical Selection:**
   ```
   μ(Π) = min(Π)  // according to some total order
   ```

2. **Consensus Median:**
   ```
   μ(Π) = median(Π)  // according to some metric
   ```

3. **Deterministic Hash:**
   ```
   μ(Π) = hash(Π) mod |Π|  // deterministic pseudorandom selection
   ```

---

### Definition 5: Transition Operator

Define the **transition operator** `T : 𝒫(𝕌) × Event → 𝒫(𝕌)`:

```
Π(t+1) = T(Π(t), e(t))
```

Where `e(t)` is an **event** (e.g., transaction, block, consensus message).

**Constraint:**
```
T(Π, e) ⊆ Π  // Transitions only eliminate possibilities
```

---

## Theorems

### Theorem 1: Finite Termination

**Statement:** If `𝕌` is finite and `∀t : ε(t+1) ∖ ε(t) ≠ ∅`, then `∃ t_max : Π(t_max) = ∅`.

**Proof:**
Since `𝕌` is finite and possibilities strictly decrease each timestep, eventually all possibilities are eliminated. ∎

**Interpretation:** A TASM-Chain must either:
1. Allow `ε(t+1) = ε(t)` (stagnation)
2. Use infinite `𝕌`
3. Terminate at finite time

---

### Theorem 2: State Determinism

**Statement:** If `μ` is deterministic, then `State(t)` is uniquely determined by `Π(t)`.

**Proof:** Direct from definition of deterministic function. ∎

**Interpretation:** Given the same possibility space, different observers compute the same state.

---

### Theorem 3: Irreversibility

**Statement:** If `Π(t+1) ⊂ Π(t)` (strict subset), then without external intervention, `Π(t)` cannot be recovered at `t' > t+1`.

**Proof:** 
By monotonic decrease property, `Π(t') ⊆ Π(t+1) ⊂ Π(t)`.
Therefore `Π(t') ≠ Π(t)`. ∎

**Interpretation:** Information loss is irreversible in TASM-Chain, mirroring thermodynamic entropy.

---

## Consensus Mechanism

### Definition 6: Consensus Function

Let `C : 𝒫(𝕌) × Votes → 𝒫(𝕌)` be a **consensus function**:

```
Π(t+1) = C(Π(t), votes(t))
```

Where `votes(t)` represents validator votes at time `t`.

**Consensus Property:**
A consensus function must satisfy:
```
C(Π, v) ⊆ Π  // Can only eliminate, not create
```

---

### Example: Majority Elimination

Validators vote on which possibilities to eliminate:

```
C(Π, votes) = Π ∖ {p ∈ Π : majority_votes_to_eliminate(p, votes)}
```

If a majority agrees a possibility is invalid, it's removed from `Π(t+1)`.

---

## Implementation Model

### Practical State Representation

In practice, we cannot store all of `Π(t)`. Instead:

```
Π(t) ≈ {s ∈ 𝕌 : ∀c ∈ Constraints(t) : c(s) = true}
```

Where `Constraints(t)` is a set of boolean predicates.

**Example:**
```
Constraints(t) = {
  balance(Alice) ≥ 0,
  balance(Bob) ≥ 0,
  nonce(Alice) = 5,
  ...
}
```

**State space:**
```
Π(t) = {all states satisfying all constraints}
```

Adding a constraint eliminates possibilities.

---

## Relationship to Traditional Models

### Traditional Blockchain:
```
State(t+1) = Apply(State(t), Transaction(t))
```

### TASM-Chain Equivalence:
```
Π(t+1) = Π(t) ∖ {s : ¬Valid(s, Transaction(t))}
State(t+1) = μ(Π(t+1))
```

**Insight:** Every state transformation can be reframed as possibility elimination.

---

## Constraints and Invariants

### Invariant 1: Non-Empty Possibility Space

For a functioning chain:
```
∀t : Π(t) ≠ ∅
```

If `Π(t) = ∅`, the system has reached a contradiction (no valid state exists).

### Invariant 2: Possibility Conservation

```
Π(t) ∪ ε(t) = 𝕌
```

At any time, possibilities are either active or eliminated—never lost.

---

## Advanced Topics

### Possibility Forking

When consensus fails, possibility spaces can diverge:

```
Π_A(t+1) = C_A(Π(t), votes_A)
Π_B(t+1) = C_B(Π(t), votes_B)
```

If `Π_A(t+1) ≠ Π_B(t+1)`, a chain split occurs.

### Possibility Merging

Can diverged chains merge?

```
Π_merged = Π_A ∩ Π_B
```

Only possibilities valid in both chains survive the merge.

---

## Conclusion

The TASM-Chain formal model provides:
1. Rigorous mathematical foundation
2. Monotonic possibility reduction
3. Consensus as collective elimination
4. Equivalence to (and alternative view of) traditional blockchains

This formalism is complete and self-consistent, serving as the kernel for further exploration.
