# TASM-Chain: Kernel Specification

## Purpose

This document specifies the core kernel interfaces and data structures for implementing a TASM-Chain system. While TASM-Chain is a thought experiment, this specification provides concrete primitives for exploration.

---

## Core Data Structures

### 1. Possibility Space

```typescript
interface PossibilitySpace {
  // Unique identifier for this possibility space
  id: Hash;
  
  // Time index
  time: number;
  
  // Constraints defining valid states
  constraints: Constraint[];
  
  // Metadata
  metadata: {
    size_estimate: number;    // Approximate |Π(t)|
    entropy: number;          // Measure of remaining uncertainty
    parent: Hash;             // Previous possibility space
  };
}
```

### 2. Constraint

A constraint is a predicate that possibilities must satisfy.

```typescript
interface Constraint {
  // Unique identifier
  id: Hash;
  
  // Human-readable description
  description: string;
  
  // Constraint type
  type: ConstraintType;
  
  // Serialized predicate
  predicate: Bytes;
  
  // Timestamp when constraint was added
  added_at: number;
  
  // Who added this constraint (validator, consensus, etc.)
  authority: PublicKey;
}

enum ConstraintType {
  BALANCE,           // e.g., balance(account) >= amount
  NONCE,            // e.g., nonce(account) == value
  MERKLE_ROOT,      // e.g., merkle_root == hash
  SIGNATURE,        // e.g., valid_signature(tx, pubkey)
  CUSTOM,           // User-defined constraint
}
```

### 3. State

The current observed state, derived from the possibility space.

```typescript
interface State {
  // Time index
  time: number;
  
  // Possibility space this state emerged from
  possibility_space: Hash;
  
  // Reduction function used
  reduction_method: string;
  
  // Actual state data (domain-specific)
  data: StateData;
  
  // Proof that this state satisfies all constraints
  proof: StateProof;
}

interface StateData {
  // Account balances
  balances: Map<Address, Amount>;
  
  // Account nonces
  nonces: Map<Address, number>;
  
  // Contract storage
  storage: Map<Address, Bytes>;
  
  // Additional domain-specific fields
  [key: string]: any;
}
```

### 4. Event

Events trigger possibility space transitions.

```typescript
interface Event {
  // Event type
  type: EventType;
  
  // Timestamp
  timestamp: number;
  
  // Event payload
  payload: Bytes;
  
  // Signature (if applicable)
  signature?: Signature;
  
  // Validator votes (for consensus events)
  votes?: Vote[];
}

enum EventType {
  TRANSACTION,      // User transaction
  CONSENSUS,        // Consensus decision
  BLOCK,           // Block finalization
  TIMEOUT,         // Time-based trigger
}
```

---

## Core Interfaces

### 1. Kernel Interface

The kernel manages possibility space evolution.

```typescript
interface Kernel {
  /**
   * Get the current possibility space
   */
  getCurrentPossibilitySpace(): PossibilitySpace;
  
  /**
   * Get the current observable state
   */
  getCurrentState(): State;
  
  /**
   * Process an event, transitioning the possibility space
   * Returns the new possibility space
   */
  processEvent(event: Event): PossibilitySpace;
  
  /**
   * Query: Is a given state possible?
   */
  isPossible(state: StateData, time: number): boolean;
  
  /**
   * Query: How many possibilities remain?
   */
  countPossibilities(time: number): bigint;
  
  /**
   * Get elimination history
   */
  getEliminationHistory(from: number, to: number): Constraint[];
}
```

### 2. Consensus Interface

Consensus determines which possibilities to eliminate.

```typescript
interface Consensus {
  /**
   * Submit a vote to eliminate certain possibilities
   */
  vote(possibilities_to_eliminate: Hash[], signature: Signature): void;
  
  /**
   * Tally votes and determine which possibilities to eliminate
   */
  tally(votes: Vote[]): Hash[];
  
  /**
   * Check if consensus has been reached
   */
  hasConsensus(): boolean;
  
  /**
   * Get current validator set
   */
  getValidators(): PublicKey[];
}
```

### 3. State Reduction Interface

Reduces a possibility space to a single state.

```typescript
interface StateReduction {
  /**
   * Reduce a possibility space to an observable state
   */
  reduce(space: PossibilitySpace): State;
  
  /**
   * Name of the reduction method
   */
  getName(): string;
}
```

---

## Kernel Operations

### Operation 1: Initialization

```typescript
function initialize(): Kernel {
  // Create universal possibility space at t=0
  const universe = createUniversalPossibilitySpace();
  
  // Initialize with no constraints
  const initial_space: PossibilitySpace = {
    id: hash(universe),
    time: 0,
    constraints: [],
    metadata: {
      size_estimate: Infinity,
      entropy: Infinity,
      parent: null,
    }
  };
  
  return new Kernel(initial_space);
}
```

### Operation 2: Transition

```typescript
function transition(
  current: PossibilitySpace,
  event: Event
): PossibilitySpace {
  // Extract constraints from event
  const new_constraints = extractConstraints(event);
  
  // Create new possibility space with additional constraints
  const next: PossibilitySpace = {
    id: hash(current.id, new_constraints),
    time: current.time + 1,
    constraints: [...current.constraints, ...new_constraints],
    metadata: {
      size_estimate: estimateSize(current, new_constraints),
      entropy: calculateEntropy(current, new_constraints),
      parent: current.id,
    }
  };
  
  // Verify at least one possibility remains
  if (next.metadata.size_estimate === 0) {
    throw new Error("Contradiction: No valid possibilities remain");
  }
  
  return next;
}
```

### Operation 3: State Observation

```typescript
function observe(
  space: PossibilitySpace,
  reduction: StateReduction
): State {
  // Use reduction function to collapse possibility space
  const state = reduction.reduce(space);
  
  // Verify state satisfies all constraints
  for (const constraint of space.constraints) {
    if (!satisfies(state.data, constraint)) {
      throw new Error(`State violates constraint: ${constraint.description}`);
    }
  }
  
  return state;
}
```

### Operation 4: Possibility Query

```typescript
function isPossible(
  space: PossibilitySpace,
  candidate: StateData
): boolean {
  // Check if candidate satisfies all constraints
  for (const constraint of space.constraints) {
    if (!satisfies(candidate, constraint)) {
      return false;  // Possibility eliminated
    }
  }
  
  return true;  // Possibility remains
}
```

---

## Example Implementation Flow

### Step 1: Genesis

```typescript
// Initialize kernel
const kernel = initialize();

// At t=0, all possibilities are open
const π_0 = kernel.getCurrentPossibilitySpace();
// π_0.constraints = []
// π_0.metadata.size_estimate = ∞
```

### Step 2: First Transaction

```typescript
// Alice sends 10 tokens to Bob
const tx1: Event = {
  type: EventType.TRANSACTION,
  timestamp: 1,
  payload: encode({
    from: "Alice",
    to: "Bob",
    amount: 10,
  }),
  signature: sign(tx1, alice_key),
};

// Process transaction
const π_1 = kernel.processEvent(tx1);

// New constraints added:
// - balance(Alice) >= 10
// - valid_signature(tx1, Alice.pubkey)
// - nonce(Alice) == previous_nonce + 1
```

### Step 3: Consensus

```typescript
// Validators vote on which possibilities to eliminate
const votes: Vote[] = [
  { validator: V1, eliminate: ["invalid_state_hash_1"] },
  { validator: V2, eliminate: ["invalid_state_hash_1"] },
  { validator: V3, eliminate: ["invalid_state_hash_2"] },
];

const consensus_event: Event = {
  type: EventType.CONSENSUS,
  timestamp: 2,
  payload: encode(votes),
  votes: votes,
};

const π_2 = kernel.processEvent(consensus_event);

// Possibilities eliminated by majority vote
```

### Step 4: State Observation

```typescript
// Reduce possibility space to observable state
const reduction = new CanonicalReduction();
const state = kernel.getCurrentState();

// State contains:
// - balances: { Alice: 90, Bob: 10 }
// - nonces: { Alice: 1 }
```

---

## Constraint Satisfaction

### Constraint Evaluation Engine

```typescript
function satisfies(state: StateData, constraint: Constraint): boolean {
  switch (constraint.type) {
    case ConstraintType.BALANCE:
      const { account, min_amount } = decode(constraint.predicate);
      return state.balances.get(account) >= min_amount;
      
    case ConstraintType.NONCE:
      const { account, value } = decode(constraint.predicate);
      return state.nonces.get(account) === value;
      
    case ConstraintType.SIGNATURE:
      const { message, pubkey, sig } = decode(constraint.predicate);
      return verify_signature(message, pubkey, sig);
      
    case ConstraintType.CUSTOM:
      return evaluateCustomConstraint(state, constraint);
      
    default:
      throw new Error(`Unknown constraint type: ${constraint.type}`);
  }
}
```

---

## Optimization Strategies

### 1. Constraint Indexing

Instead of storing all states in `Π(t)`, store only the constraints:

```typescript
class CompactPossibilitySpace {
  constraints: Constraint[];
  
  // Lazily enumerate possibilities
  *enumerate(): Generator<StateData> {
    // Generate states satisfying all constraints
    yield* satisfyingStates(this.constraints);
  }
}
```

### 2. Incremental Constraint Checking

When adding a new constraint, only check compatibility with recent constraints:

```typescript
function isCompatible(c1: Constraint, c2: Constraint): boolean {
  // Check if c1 and c2 can both be satisfied
  // Use SAT solver or constraint programming
}
```

### 3. Merkle Constraint Trees

Organize constraints in a Merkle tree for efficient proofs:

```typescript
class ConstraintTree {
  root: Hash;
  
  prove(constraint: Constraint): Proof {
    // Generate Merkle proof for constraint inclusion
  }
  
  verify(constraint: Constraint, proof: Proof): boolean {
    // Verify constraint is in the tree
  }
}
```

---

## Security Considerations

### 1. Constraint Flooding

**Attack:** Adversary adds many constraints to bloat `Π(t)`.

**Mitigation:** 
- Rate limit constraint additions
- Require stake or fees to add constraints
- Prune redundant constraints

### 2. Contradiction Injection

**Attack:** Adversary adds conflicting constraints to make `Π(t) = ∅`.

**Mitigation:**
- Validate constraint consistency before acceptance
- Use constraint compatibility checking
- Implement constraint rollback on contradiction

### 3. State Grinding

**Attack:** Adversary searches for reduction functions that favor them.

**Mitigation:**
- Use deterministic reduction functions
- Commit to reduction method in advance
- Validate state proofs

---

## Extension Points

### 1. Smart Contracts as Constraint Generators

```typescript
interface SmartContract {
  generateConstraints(event: Event): Constraint[];
}
```

Contracts emit constraints that restrict future possibilities.

### 2. Probabilistic Possibilities

```typescript
interface WeightedPossibilitySpace {
  possibilities: Map<StateData, number>;  // State -> Probability
}
```

Some states are more "likely" than others.

### 3. Quantum-Inspired Superposition

```typescript
interface QuantumState {
  superposition: Map<StateData, Complex>;  // State -> Amplitude
}
```

States exist in superposition until observed (reduced).

---

## Conclusion

This specification provides:

1. **Core data structures** for representing possibility spaces
2. **Interfaces** for kernel operations
3. **Concrete algorithms** for state transition and observation
4. **Security considerations** for production implementations
5. **Extension points** for future research

While TASM-Chain remains a thought experiment, these specifications enable concrete exploration of the possibility-collapse paradigm.

**Remember:** State changes because possibilities disappear over time.
