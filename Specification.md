# TASM Kernel — Formal Specification

This document defines the canonical formal specification
of the TASM (Time–Absence State Machine) kernel.

The specification is normative.
The code is an implementation of this document.

---

## 1. Primitive Domains

### Time

Let T be a totally ordered, monotonic set.

Properties:
- linear
- irreversible
- no backward transitions

---

### Action

Let A be an opaque, uninterpreted set.

No structure is assumed.

---

### Intent

An Intent is a pair:

E = (a, T_E)

where:
- a ∈ A
- T_E ∈ T

---

## 2. Observation Predicate

Obs(a, t) denotes that action `a`
was observed at or before time `t`.

### Monotonicity
Obs(a, t₁) ∧ t₁ ≤ t₂ ⇒ Obs(a, t₂)

Observation is optional.

---

## 3. Absence Predicate

Abs(E, t) is defined as:

Abs(E, t) ≡ (T_E ≤ t) ∧ ¬Obs(a, T_E)

Absence is:
- not an event
- not an instruction
- a logical fact

---

## 4. No Late Action Axiom

For any E = (a, T_E):

t ≥ T_E ⇒ ¬Obs(a, t)

This axiom forbids worlds
in which actions occur after deadlines.

---

## 5. System State

At time t, the system state is:

S(t) = { E | Abs(E, t) }

State is a monotonic set.

---

## 6. State Evolution Law

The system admits exactly one transition:

¬Obs(a, T_E) ∧ T_E ≤ t ⇒ E ∈ S(t)

No transition removes elements from S(t).

---

## 7. Invariants

### I1 — Irreversibility
E ∈ S(t₁) ∧ t₁ ≤ t₂ ⇒ E ∈ S(t₂)

### I2 — Silence Binding
If no observation occurs before T_E,
Abs(E, t) becomes true at t ≥ T_E.

### I3 — No Override
No actor or instruction may modify S(t)
other than via time progression.

### I4 — Actor Independence
Correctness of S(t) does not depend
on user activity or liveness.

---

## 8. Correspondence to Code

| Formal Concept | Code Representation |
|---------------|--------------------|
| Time | `Time` |
| Intent | `Intent` |
| Obs | `observations: Map<ActionId, Time>` |
| Abs | `absences: Set<IntentId>` |
| State evolution | `advance_time()` |

The code is correct iff all invariants hold.

---

## 9. Closure

This specification is complete.

Any system that introduces:
- reversibility
- execution-driven transitions
- governance overrides

is not a TASM system.

