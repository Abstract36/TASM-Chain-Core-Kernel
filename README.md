# TASM — Time–Absence State Machines

[![Check](https://github.com/Abstract36/TASM-Chain-Core-Kernel/actions/workflows/check.yml/badge.svg)](https://github.com/Abstract36/TASM-Chain-Core-Kernel/actions/workflows/check.yml)

A class of systems where **state evolves because time passes, not because
actions occur.**

The machine does not execute transactions. It records **what became
impossible** once a deadline elapsed. An action not observed before its
deadline is absent, permanently.

## What is checked, and by what

| Claim | Checked by | Result |
| --- | --- | --- |
| The theory is consistent and non-vacuous | `lean formal/TASM.lean` | 0 errors; a model is exhibited |
| Absence is irreversible | Lean 4.35.0 | `TASM.absence_irreversible` |
| State only grows | Lean 4.35.0 | `TASM.state_monotone` |
| An absence closes the door for good | Lean 4.35.0 | `TASM.absence_closes_the_door` |
| No proof leans on an axiom | `#print axioms` | all four: *does not depend on any axioms* |
| The kernel runs and obeys the theorems | `cargo test` in `kernel/` | 5 of 5 invariants pass |

Reproduce both in under a minute:

```bash
curl -sSf https://elan.lean-lang.org/elan-init.sh | sh   # or: apt install elan
lean formal/TASM.lean
lean formal/Vacuity.lean
cd kernel && cargo test
```

`formal/TASM.v` transcribes the same development into Coq. **It has not been
run** — no Coq toolchain was available when this was written. Treat the Lean
files as the formalization and the Coq file as a transcription.

## The assumptions

They are fields of a structure, not global axioms, and every theorem takes
them as parameters:

```lean
structure TASM (Action : Type u) (Time : Type u) where
  le : Time → Time → Prop
  Observed : Action → Time → Prop
  total : ∀ t₁ t₂, le t₁ t₂ ∨ le t₂ t₁
  trans : ∀ t₁ t₂ t₃, le t₁ t₂ → le t₂ t₃ → le t₁ t₃
  observed_monotone : ∀ a t₁ t₂, Observed a t₁ → le t₁ t₂ → Observed a t₂
  no_late_action : ∀ (E : Intent Action Time) (t : Time),
    ¬ Observed E.act E.deadline → le E.deadline t → ¬ Observed E.act t
```

`no_late_action` is the law of the machine: *not done by the deadline means
never done.*

## A correction worth recording

The first published version of this repository stated `no_late_action`
**without its first hypothesis** — as "no action is observed at or after its
deadline", full stop. That version was consistent, and both theorems checked
out, and it was still wrong.

Because `total` instantiated at a single point gives reflexivity, the
unconditional form applies to every intent at its own deadline, and from
there to every action at every time. The axioms forced

```
∀ a t, ¬ Observed a t
```

— an empty observation relation, a world in which nothing is ever done, where
`Absence` collapses to "the deadline has passed" and the two surviving
theorems restate transitivity. `formal/Vacuity.lean` proves exactly this, from
the published assumptions, and Lean checks it.

That is the gap "machine-checked" does not cover. A proof assistant verifies
that conclusions follow from assumptions. It will not tell you the assumptions
describe a world where anything can happen. Only a model does that, which is
why `formal/TASM.lean` now ends with one.

The Rust kernel never had the bug: `observe_action` refuses an observation
only at or after a deadline, so actions remain observable. The implementation
was right and the formalization was wrong — the opposite of the usual order.

## Layout

```
formal/TASM.lean      the development: assumptions, four theorems, a model
formal/Vacuity.lean   proof that the superseded axioms admit only the empty relation
formal/TASM.v         Coq transcription (not run)
kernel/src/kernel.rs  the kernel: no_std, single node, one transition driver
kernel/tests/         five invariants, each the executable form of a theorem
Mathematical_Model.md
Specification.md      normative; the code is correct iff it satisfies this
Core_Kernel.md
```

The kernel has exactly one state transition driver, `advance_time(t)`.
Everything else is derived.

## What this is not

No consensus, networking, incentives, execution engine, accounts, balances,
governance or upgrade path. Adding any of them changes the system class.

## Status

The formal development and the kernel are finished and checked. There is no
roadmap and no launch. The artifact exists to show that such a system is
consistent, specifiable, and implementable without contradiction — and the
checks above are there so that claim can be tested rather than taken.
