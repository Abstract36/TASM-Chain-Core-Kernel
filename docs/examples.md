# TASM-Chain: Examples

This document provides concrete examples of TASM-Chain concepts in action.

---

## Example 1: Simple Token Transfer

### Scenario
Alice wants to send 10 tokens to Bob.

### Traditional Blockchain View

```
State(t0):
  Alice: 100 tokens
  Bob: 0 tokens

Transaction: Alice → Bob (10 tokens)

State(t1):
  Alice: 90 tokens
  Bob: 10 tokens
```

### TASM-Chain View

```
Π(t0): {
  All states where:
    - total_supply = 100 tokens
    - Alice + Bob = 100 tokens
    - Alice ≥ 0, Bob ≥ 0
}

Size: Infinite (uncountably many distributions possible)

Event: Transaction(Alice → Bob, 10 tokens)

New Constraints:
  1. Alice.balance(t1) = Alice.balance(t0) - 10
  2. Bob.balance(t1) = Bob.balance(t0) + 10
  3. valid_signature(tx, Alice.pubkey)

Π(t1): {
  All states where:
    - total_supply = 100 tokens
    - Alice = 90 tokens  (constrained!)
    - Bob = 10 tokens    (constrained!)
}

Size: 1 (only one state remains possible)

Observation: State(t1) = μ(Π(t1)) = { Alice: 90, Bob: 10 }
```

**Key Insight:** The transaction didn't *transform* state—it *eliminated possibilities* until only one remained.

---

## Example 2: Chain Fork

### Scenario
Two validators disagree on which transaction came first.

### Traditional View

```
State(t0): Alice: 100, Bob: 0, Carol: 0

Fork:
  Chain A: Alice → Bob (100 tokens)
  Chain B: Alice → Carol (100 tokens)

Result: Two chains with different states
```

### TASM-Chain View

```
Π(t0): {
  All states where Alice + Bob + Carol = 100
}

Validator Set A eliminates:
  ε_A = { states where Alice → Carol occurred }

Validator Set B eliminates:
  ε_B = { states where Alice → Bob occurred }

Π_A(t1) = Π(t0) ∖ ε_A = { states where Alice → Bob }
Π_B(t1) = Π(t0) ∖ ε_B = { states where Alice → Carol }

Π_A(t1) ∩ Π_B(t1) = ∅  (no common possibilities!)
```

**Key Insight:** Fork = divergent possibility elimination.

**Merge Condition:**
```
Π_merged = Π_A ∩ Π_B
```

If `Π_merged ≠ ∅`, chains can merge. Otherwise, irreconcilable.

---

## Example 3: Smart Contract as Constraint Generator

### Scenario
Escrow contract: "Release funds only if both Alice and Bob sign."

### Contract Code

```typescript
class EscrowContract implements SmartContract {
  generateConstraints(event: Event): Constraint[] {
    if (event.type === EventType.RELEASE) {
      return [
        {
          id: hash("escrow_alice_sig"),
          description: "Alice must sign release",
          type: ConstraintType.SIGNATURE,
          predicate: encode({ 
            message: event.payload, 
            pubkey: alice.pubkey 
          })
        },
        {
          id: hash("escrow_bob_sig"),
          description: "Bob must sign release",
          type: ConstraintType.SIGNATURE,
          predicate: encode({ 
            message: event.payload, 
            pubkey: bob.pubkey 
          })
        }
      ];
    }
    return [];
  }
}
```

### Execution Flow

```
Π(t0): { All states where escrow holds 100 tokens }

Event: Release Request (signed by Alice only)

New Constraints:
  - valid_signature(release, Alice)  ✓
  - valid_signature(release, Bob)    ✗

Π(t1) = Π(t0) ∖ { states where release succeeded }
      = Π(t0)  (no possibilities eliminated)

State remains unchanged.

---

Event: Release Request (signed by both Alice and Bob)

New Constraints:
  - valid_signature(release, Alice)  ✓
  - valid_signature(release, Bob)    ✓

Π(t2) = Π(t1) ∖ { states where funds are NOT released }

Only states where funds are released remain possible.
```

---

## Example 4: Temporal Reasoning

### Scenario
Timelock: "Alice can withdraw only after block 100."

### Constraint Representation

```typescript
const timelock_constraint: Constraint = {
  id: hash("timelock_100"),
  description: "Withdrawal impossible before block 100",
  type: ConstraintType.CUSTOM,
  predicate: encode({
    condition: "block_height < 100 → withdrawal = false"
  })
};
```

### Evolution Over Time

```
Π(t=99): {
  States where withdrawal has NOT occurred
  (all withdrawal states eliminated)
}

Π(t=100): {
  States where withdrawal MAY have occurred
  (withdrawal possibilities return!)
}

Π(t=101): {
  States where withdrawal MAY have occurred
  (possibilities remain stable)
}
```

**Key Insight:** Time itself acts as a possibility filter. At `t=100`, possibilities that were eliminated become available again—not because state changed, but because *constraints changed*.

---

## Example 5: Non-Deterministic State Reduction

### Scenario
Multiple valid states exist; observers may see different states.

### Setup

```
Π(t): {
  State A: Alice: 50, Bob: 50
  State B: Alice: 40, Bob: 60
  State C: Alice: 60, Bob: 40
}

All three states satisfy all constraints.
```

### Reduction Methods

#### Canonical Reduction (Deterministic)
```typescript
μ_canonical(Π) = min(Π)  // Select lexicographically first state
Result: State A (deterministic across all observers)
```

#### Random Reduction (Non-Deterministic)
```typescript
μ_random(Π) = random(Π)  // Select randomly

Observer 1 sees: State A
Observer 2 sees: State C
Observer 3 sees: State B
```

**Implication:** Non-deterministic reduction leads to observer-dependent reality!

#### Consensus Reduction
```typescript
μ_consensus(Π) = majority_vote(Π, validators)

Validators vote:
  V1 → State A
  V2 → State A
  V3 → State B

Result: State A (consensus majority)
```

---

## Example 6: Contradiction Handling

### Scenario
Conflicting constraints create an empty possibility space.

### Setup

```
Constraint 1: Alice.balance ≥ 50
Constraint 2: Bob.balance ≥ 50
Constraint 3: Alice + Bob = 80
```

### Analysis

```
Π = { states where:
  Alice ≥ 50
  Bob ≥ 50
  Alice + Bob = 80
}

Minimum sum: 50 + 50 = 100
Required sum: 80

100 > 80  →  Contradiction!

Π = ∅  (empty set)
```

### Resolution Strategies

#### 1. Reject Latest Constraint
```typescript
if (addConstraint(c) results in Π = ∅) {
  reject(c);
  Π remains unchanged;
}
```

#### 2. Rollback to Consistent State
```typescript
if (Π = ∅) {
  rollback to Π(t-1);
  mark current event as invalid;
}
```

#### 3. Fork Chain
```typescript
if (Π = ∅) {
  create new chain without conflicting constraint;
  split consensus;
}
```

---

## Example 7: Possibility Space Size Over Time

### Scenario
Track how possibilities decrease as constraints accumulate.

### Visualization

```
t=0:  Π(0) = 𝕌               |Π| = ∞
      (No constraints)

t=1:  Alice: 100 tokens      |Π| ≈ 10^20
      (Balance constraint)

t=2:  Bob: 50 tokens         |Π| ≈ 10^15
      (Another balance)

t=3:  Tx: Alice → Bob (10)   |Π| ≈ 10^10
      (Transaction constraint)

t=4:  Block hash: 0xABC...   |Π| = 1
      (Complete determinism)
```

**Graph:**
```
|Π|
 ∞  │●
    │ ╲
10^20│  ●
    │   ╲
10^15│    ●
    │     ╲
10^10│      ●
    │       ╲
  1 │        ●
    └─────────────── time
    0  1  2  3  4
```

**Entropy decreases monotonically.**

---

## Example 8: Possibility Merging After Fork

### Scenario
Two chains fork, then attempt to merge.

### Setup

```
Π(t0): { All states with total_supply = 1000 }

Fork at t1:
  Chain A: Alice → Bob (100)
  Chain B: Alice → Carol (200)

Π_A(t1): { states where Bob +100, Alice -100 }
Π_B(t1): { states where Carol +200, Alice -200 }

Π_A ∩ Π_B = ∅  (incompatible)
```

### Merge Attempt 1: Intersection (Fails)

```
Π_merged = Π_A ∩ Π_B = ∅

No common possibilities → Merge impossible.
```

### Merge Attempt 2: Union (Expands)

```
Π_merged = Π_A ∪ Π_B

Result: Possibility space INCREASES (violates monotonicity!)

Not allowed in TASM-Chain.
```

### Merge Attempt 3: Constraint Negotiation

```
Remove conflicting constraints:
  Remove: Alice → Bob (100)
  Remove: Alice → Carol (200)
  
Keep: All other constraints from both chains

Π_merged = Π(t0) with remaining constraints

Result: Valid, but loses transaction history.
```

**Conclusion:** Some forks cannot be merged without information loss.

---

## Example 9: Quantum-Inspired Superposition

### Extension: Weighted Possibilities

```typescript
interface WeightedPossibility {
  state: StateData;
  amplitude: Complex;
}

interface QuantumPossibilitySpace {
  possibilities: WeightedPossibility[];
}
```

### Example

```
Π(quantum) = {
  State A: amplitude = 0.6 + 0.0i  (|amplitude|² = 36% probability)
  State B: amplitude = 0.8 + 0.0i  (|amplitude|² = 64% probability)
}

Observation (measurement) collapses to one state:
  64% chance → State B
  36% chance → State A
```

**Analogy to quantum mechanics:** Multiple states exist simultaneously until "measured" (reduced to observable state).

---

## Example 10: Real-World Analogy

### Bank Account

#### Traditional Model:
"Your balance is $1000. You make a deposit of $100. Your new balance is $1100."

#### TASM Model:
"Before the deposit, all balances were possible. After the deposit, only balances of $1100 remain possible (given initial $1000 + $100 deposit). Your observed balance is what remains after impossibilities are eliminated."

### Insight:
Both models describe the same reality, but TASM emphasizes:
- **What could have been** (possibilities)
- **What cannot be** (eliminations)
- **What is** (residue)

Traditional models emphasize:
- **What was** (previous state)
- **What happened** (transformation)
- **What is now** (current state)

---

## Conclusion

These examples demonstrate:

1. **Equivalence** to traditional models
2. **Alternative perspective** on state transitions
3. **Handling edge cases** (forks, contradictions, merges)
4. **Extensions** (quantum-inspired, weighted probabilities)

TASM-Chain is not a replacement for traditional blockchains—it's a **reframing** that may offer insights into consensus, forking, and state management.

**Remember:** State changes because possibilities disappear over time.
