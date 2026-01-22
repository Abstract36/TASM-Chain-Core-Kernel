# TASM-Chain — Core Kernel

This document defines the **core kernel** of a blockchain system
derived strictly from the TASM (Time–Absence State Machine)
mathematical formalization.

This is **not an implementation guide**.
This is **not a product specification**.
This is the minimal executable interpretation of a formal system.

---

## 1. Kernel Principle

> The kernel does not execute actions.  
> The kernel computes impossibilities.

State evolves because time passes,
not because someone acts.

---

## 2. Ontological Scope

The kernel is responsible for exactly three things:

1. Tracking monotonic time
2. Tracking declared intents with deadlines
3. Deriving irreversible absence facts

Everything else is out of scope.

---

## 3. Primitive Types

- **Time**  
  A monotonic, irreversible scalar.

- **ActionID**  
  An opaque identifier of a possible action.

- **IntentID**  
  An opaque identifier of a declared intent.

---

## 4. Intent

An Intent declares the *possibility of becoming late*.

Intent = (ActionID, Deadline)

yaml
Копировать код

Properties:
- An intent does not promise execution
- An intent does not guarantee outcome
- An intent only introduces a future point of impossibility

---

## 5. Observation (Secondary)

An observation records that an action occurred
before a deadline.

Observations:
- are optional
- do not cause state transitions
- only prevent absence

The kernel remains correct without observations.

---

## 6. Absence Fact

An **Absence** is not an event.
It is not created by instruction.

It is a logical consequence:

> If the deadline passed  
> and the action was not observed  
> then absence is true forever.

Absence is:
- irreversible
- monotonic
- non-interactive

---

## 7. Kernel State

At any time `t`, the state is:

State(t) = { all Absence facts true at time t }

yaml
Копировать код

There are:
- no balances
- no mutable objects
- no partial execution states

State is a growing set of impossibilities.

---

## 8. Time Advancement

Time advancement is the **only driver** of state change.

When time advances:
- no action is executed
- no transition is called
- absence facts are derived

The kernel remains valid even if:
- no intents are declared
- no actions are observed

---

## 9. Blocks

A block represents a **time window**.

A block contains:
- the time interval
- the set of Absence facts that became true

Empty blocks are valid.

Silence is meaningful.

---

## 10. Invariants

The kernel MUST satisfy:

1. **Irreversibility**  
   Absence facts are never removed.

2. **No Late Action**  
   Actions after deadlines are forbidden.

3. **Monotonic State**  
   State(t₁) ⊆ State(t₂) for t₂ ≥ t₁.

4. **No Override**  
   No instruction can modify absence.

---

## 11. Explicit Non-Features

The kernel does NOT contain:

- execution engine
- virtual machine
- gas or fees
- governance
- emergency paths
- upgrade hooks
- retries or forgiveness

Adding any of these changes the system class.

---

## 12. Kernel Correctness Criterion

If the kernel runs with:
- only time advancing
- no user interaction

and the set of impossibilities still grows,

then the kernel is correct.

---

## 13. Closing Statement

This kernel does not ask what happened.

It records only what can no longer happen.

That is sufficient.
