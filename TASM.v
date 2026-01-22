(* TASM Core Formalization *)
(* Coq style *)

Section TASM.

Variable Time : Type.
Variable le : Time -> Time -> Prop.

Axiom time_linear :
  forall t1 t2 : Time, le t1 t2 \/ le t2 t1.

Axiom time_trans :
  forall t1 t2 t3 : Time,
    le t1 t2 -> le t2 t3 -> le t1 t3.

Variable Action : Type.

Record Intent := {
  act : Action;
  deadline : Time
}.

Variable Observed : Action -> Time -> Prop.

Axiom observed_monotone :
  forall a t1 t2,
    Observed a t1 ->
    le t1 t2 ->
    Observed a t2.

Definition Absence (E : Intent) (t : Time) : Prop :=
  le (deadline E) t /\ ~ Observed (act E) (deadline E).

Axiom no_late_action :
  forall E t,
    le (deadline E) t ->
    ~ Observed (act E) t.

Theorem absence_irreversible :
  forall E t1 t2,
    Absence E t1 ->
    le t1 t2 ->
    Absence E t2.
Proof.
  intros E t1 t2 H Hle.
  split.
  - apply (time_trans _ _ _ (proj1 H) Hle).
  - exact (proj2 H).
Qed.

Definition State (t : Time) : Intent -> Prop :=
  fun E => Absence E t.

Theorem state_monotone :
  forall t1 t2,
    le t1 t2 ->
    forall E,
      State t1 E ->
      State t2 E.
Proof.
  intros t1 t2 Hle E H.
  apply absence_irreversible with (t1 := t1); assumption.
Qed.

End TASM.
