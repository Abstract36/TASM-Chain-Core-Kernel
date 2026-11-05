/-!
# The published TASM axioms admit only the empty observation relation

Stated as a theorem over the axioms rather than against global `axiom`
declarations, so it says something stronger: *every* model of the published
assumptions has an empty `Observed`.
-/

universe u

structure Intent (Time : Type u) (Action : Type u) where
  act : Action
  deadline : Time

theorem published_axioms_force_empty_observation
    {Time Action : Type u}
    (le : Time → Time → Prop)
    (Observed : Action → Time → Prop)
    -- `time_linear`, exactly as published
    (time_linear : ∀ t₁ t₂ : Time, le t₁ t₂ ∨ le t₂ t₁)
    -- `no_late_action`, exactly as published: no hypothesis about the deadline
    (no_late_action : ∀ (E : Intent Time Action) (t : Time),
        le E.deadline t → ¬ Observed E.act t) :
    ∀ (a : Action) (t : Time), ¬ Observed a t := by
  intro a t
  -- Reflexivity is derivable: instantiate linearity at a single point.
  have hrefl : le t t := by
    cases time_linear t t with
    | inl h => exact h
    | inr h => exact h
  -- Build the intent whose deadline is this very time; reflexivity then
  -- discharges the hypothesis and the action is unobservable here.
  exact no_late_action ⟨a, t⟩ t hrefl

#print axioms published_axioms_force_empty_observation
