# TASM — Time–Absence State Machines

This repository contains a **fully formalized kernel** for a class of systems called  
**Time–Absence State Machines (TASM)**.

TASM is not a product, not a protocol proposal, and not a network roadmap.  
It is a **completed formal artifact**: a mathematical law, its executable kernel, and its machine-checked specification.

---

## What TASM Is

TASM defines systems where:

> **State evolves because time passes, not because actions occur.**

The system does not execute transactions.  
It records **what became impossible** once deadlines elapsed.

If an action was not observed before its deadline,  
that absence becomes a permanent, irreversible fact.

---

## What This Repository Contains

### 1. Mathematical Model
A closed formal system defining:
- time as a monotonic order
- intents as (action, deadline)
- absence as a logical consequence of time
- state as a monotonic set of impossibilities

No execution semantics are assumed.

---

### 2. Core Kernel (Code)
A minimal, deterministic kernel:
- written in Rust
- `no_std` compatible
- single-node, no network
- no VM, no balances, no governance

The kernel has exactly **one state transition driver**:
advance_time(t)

Everything else is derived.

---

### 3. Formal Specification
A canonical specification stating:
- axioms
- invariants
- state evolution law
- correspondence between math and code

This document is normative.
The code is correct **iff** it satisfies the spec.

---

### 4. Formal Proofs (Lean / Coq)
Machine-checkable formalizations showing:
- absence irreversibility
- state monotonicity
- internal consistency

No classical logic is required for consistency.

---

## What TASM Is Not

This repository intentionally does **not** include:
- consensus
- networking
- incentives
- execution engines
- accounts or balances
- governance
- upgrade paths

Adding any of these changes the system class.

---

## Design Principles

- **Silence has meaning**
- **Inaction has consequences**
- **Deadlines are ontological**
- **State is derived, not mutated**
- **Correctness does not depend on users**

The system remains correct even if no one interacts with it.

---

## Status

This project is **complete by construction**.

There is no roadmap.
There are no planned features.
There is no launch.

The artifact exists as a proof that such a system is:
- logically consistent
- formally specifiable
- implementable without contradiction

---

## How to Read This Repository

Recommended order:
1. `Mathematical Model.md`
2. `Formal Specification.md`
3. `src/lib.rs` (no_std kernel)
4. `Lean / Coq formalization`

Each layer strictly depends on the previous one.

---

## Final Statement

TASM demonstrates that a blockchain kernel can exist where:

> **Time alone removes futures from possibility,  
> and no actor is required for correctness.**

Nothing more is claimed.
Nothing less is needed.
