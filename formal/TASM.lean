/-!
# TASM — Time–Absence State Machines

State evolves because deadlines elapse, not because actions occur. The machine
records what became impossible.

The assumptions are fields of a structure rather than global axioms. Global
axioms are what let the published version collapse unnoticed: because `le` was
total, it was reflexive, and the unconditional `no_late_action` then forced
`¬ Observed a t` for every action and every time. See `Vacuity.v`.

This file uses no Mathlib: `lean TASM.lean` checks it on a bare toolchain.
-/

universe u

/-- An action together with the deadline by which it must be observed. -/
structure Intent (Action : Type u) (Time : Type u) where
  act : Action
  deadline : Time

/-- What TASM assumes about time and observation. -/
structure TASM (Action : Type u) (Time : Type u) where
  /-- The ordering on time. -/
  le : Time → Time → Prop
  /-- `Observed a t` holds when action `a` has been observed by time `t`. -/
  Observed : Action → Time → Prop
  /-- Time is total. Reflexivity follows by taking `t₁ = t₂`. -/
  total : ∀ t₁ t₂, le t₁ t₂ ∨ le t₂ t₁
  trans : ∀ t₁ t₂ t₃, le t₁ t₂ → le t₂ t₃ → le t₁ t₃
  /-- An observation is a permanent record. -/
  observed_monotone : ∀ a t₁ t₂, Observed a t₁ → le t₁ t₂ → Observed a t₂
  /-- The law of the machine: an action not observed by its deadline can
  never be observed afterwards. The hypothesis is what the published
  version omitted. -/
  no_late_action : ∀ (E : Intent Action Time) (t : Time),
    ¬ Observed E.act E.deadline → le E.deadline t → ¬ Observed E.act t

namespace TASM

variable {Action Time : Type u} (M : TASM Action Time)

/-- Time is reflexive, derived rather than assumed. -/
theorem le_refl (t : Time) : M.le t t := by
  cases M.total t t with
  | inl h => exact h
  | inr h => exact h

/-- An intent is absent at `t` once its deadline has passed unobserved. -/
def Absence (E : Intent Action Time) (t : Time) : Prop :=
  M.le E.deadline t ∧ ¬ M.Observed E.act E.deadline

/-- Absence never lifts. -/
theorem absence_irreversible (E : Intent Action Time) (t₁ t₂ : Time)
    (h : M.Absence E t₁) (hle : M.le t₁ t₂) : M.Absence E t₂ :=
  ⟨M.trans _ _ _ h.left hle, h.right⟩

/-- The state at `t`: the intents absent at `t`. -/
def State (t : Time) (E : Intent Action Time) : Prop := M.Absence E t

/-- The state only grows. -/
theorem state_monotone (t₁ t₂ : Time) (hle : M.le t₁ t₂)
    (E : Intent Action Time) (h : M.State t₁ E) : M.State t₂ E :=
  M.absence_irreversible E t₁ t₂ h hle

/-- Absence closes the door: the action is unobservable at `t`, not merely
unrecorded at the deadline. This is what `no_late_action` buys, and what the
published axioms could not state without being trivial. -/
theorem absence_closes_the_door (E : Intent Action Time) (t : Time)
    (h : M.Absence E t) : ¬ M.Observed E.act t :=
  M.no_late_action E t h.right h.left

end TASM

/-! ## A model

The hypotheses are satisfiable with a non-empty observation relation — the
property the published axioms destroyed. Actions are booleans; a `true`
action is one that was carried out, a `false` action one that never was.
-/

def model : TASM Bool Nat where
  le := (· ≤ ·)
  Observed a _ := a = true
  total t₁ t₂ := Nat.le_total t₁ t₂
  trans _ _ _ h₁ h₂ := Nat.le_trans h₁ h₂
  observed_monotone _ _ _ h _ := h
  no_late_action _ _ h _ := h

/-- Something is observed: this is not the empty model. -/
example : model.Observed true 0 := rfl

/-- And something is absent: an action never carried out, past its deadline. -/
example : model.Absence ⟨false, 3⟩ 7 :=
  ⟨(by decide : (3 : Nat) ≤ 7), fun h => Bool.noConfusion h⟩

/-! ## What the proofs depend on -/

#print axioms TASM.le_refl
#print axioms TASM.absence_irreversible
#print axioms TASM.state_monotone
#print axioms TASM.absence_closes_the_door
