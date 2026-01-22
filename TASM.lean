-- TASM Core Formalization
-- Lean 4 style

universe u

/-- Time is a totally ordered, monotonic domain. -/
variable (Time : Type u)
variable (le : Time → Time → Prop)

axiom time_linear :
  ∀ t₁ t₂ : Time, le t₁ t₂ ∨ le t₂ t₁

axiom time_trans :
  ∀ t₁ t₂ t₃ : Time,
    le t₁ t₂ → le t₂ t₃ → le t₁ t₃

/-- Actions are opaque. -/
variable (Action : Type u)

/-- Intent = action + deadline -/
structure Intent where
  act : Action
  deadline : Time

/-- Observation predicate -/
variable (Observed : Action → Time → Prop)

/-- Observation monotonicity -/
axiom observed_monotone :
  ∀ a t₁ t₂,
    Observed a t₁ → le t₁ t₂ → Observed a t₂

/-- Absence definition -/
def Absence (E : Intent Action Time) (t : Time) : Prop :=
  le E.deadline t ∧ ¬ Observed E.act E.deadline

/-- No late action axiom -/
axiom no_late_action :
  ∀ (E : Intent Action Time) t,
    le E.deadline t → ¬ Observed E.act t

/-- Absence irreversibility -/
theorem absence_irreversible :
  ∀ (E : Intent Action Time) t₁ t₂,
    Absence Action Time le Observed E t₁ →
    le t₁ t₂ →
    Absence Action Time le Observed E t₂ :=
by
  intro E t₁ t₂ h hle
  constructor
  · exact time_trans Time le _ _ _ h.left hle
  · exact h.right

/-- State at time t = set of absences -/
def State (t : Time) : Set (Intent Action Time) :=
  { E | Absence Action Time le Observed E t }

/-- Monotonicity of state -/
theorem state_monotone :
  ∀ t₁ t₂,
    le t₁ t₂ →
    State Action Time le Observed t₁ ⊆
    State Action Time le Observed t₂ :=
by
  intro t₁ t₂ hle E hE
  exact absence_irreversible Action Time le Observed E t₁ t₂ hE hle
