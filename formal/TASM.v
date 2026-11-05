(* TASM — Time–Absence State Machines, core formalization.
   Assumptions are section parameters, not global axioms, so the theory
   cannot be made vacuous out of sight; a model is exhibited at the end. *)

Require Import Lia.

Section TASM.

Variable Time : Type.
Variable le : Time -> Time -> Prop.

Hypothesis le_total :
  forall t1 t2 : Time, le t1 t2 \/ le t2 t1.

Hypothesis le_trans :
  forall t1 t2 t3 : Time,
    le t1 t2 -> le t2 t3 -> le t1 t3.

Variable Action : Type.

Record Intent := { act : Action; deadline : Time }.

Variable Observed : Action -> Time -> Prop.

(* Once observed, always observed: an observation is a permanent record. *)
Hypothesis observed_monotone :
  forall a t1 t2, Observed a t1 -> le t1 t2 -> Observed a t2.

(* The law of the machine. If the action was NOT observed by its deadline,
   it can never be observed afterwards.

   The published version omitted the first hypothesis, which made the
   statement apply to every intent unconditionally. Because le is reflexive
   (take t1 = t2 in le_total), that forced ~ Observed a t for every action
   and every time: the observation relation was empty and the whole theory
   described a world in which nothing is ever done. See Vacuity.v. *)
Hypothesis no_late_action :
  forall E t,
    ~ Observed (act E) (deadline E) ->
    le (deadline E) t ->
    ~ Observed (act E) t.

(* An intent is absent at t once its deadline has passed without observation. *)
Definition Absence (E : Intent) (t : Time) : Prop :=
  le (deadline E) t /\ ~ Observed (act E) (deadline E).

Theorem absence_irreversible :
  forall E t1 t2, Absence E t1 -> le t1 t2 -> Absence E t2.
Proof.
  intros E t1 t2 H Hle.
  split.
  - exact (le_trans _ _ _ (proj1 H) Hle).
  - exact (proj2 H).
Qed.

Definition State (t : Time) : Intent -> Prop := fun E => Absence E t.

Theorem state_monotone :
  forall t1 t2, le t1 t2 -> forall E, State t1 E -> State t2 E.
Proof.
  intros t1 t2 Hle E H.
  exact (absence_irreversible E t1 t2 H Hle).
Qed.

(* The absence carries real content: the action is unobservable at every
   later time, not merely unrecorded at the deadline. This is the statement
   the no_late_action hypothesis actually buys, and the published version
   could not state it non-trivially. *)
Theorem absence_closes_the_door :
  forall E t, Absence E t -> ~ Observed (act E) t.
Proof.
  intros E t H.
  exact (no_late_action E t (proj2 H) (proj1 H)).
Qed.

End TASM.

(* A model, to show the hypotheses are satisfiable with a non-empty
   observation relation — the property the published axioms destroyed. *)
Section Model.

Definition MTime := nat.
Definition Mle := Nat.le.
Definition MAction := bool.
Definition MObserved (a : MAction) (_ : MTime) : Prop := a = true.

Lemma m_total : forall t1 t2, Mle t1 t2 \/ Mle t2 t1.
Proof. intros; unfold Mle; lia. Qed.

Lemma m_trans : forall t1 t2 t3, Mle t1 t2 -> Mle t2 t3 -> Mle t1 t3.
Proof. intros; unfold Mle in *; lia. Qed.

Lemma m_monotone :
  forall a t1 t2, MObserved a t1 -> Mle t1 t2 -> MObserved a t2.
Proof. unfold MObserved; auto. Qed.

Lemma m_no_late :
  forall (E : Intent MTime MAction) t,
    ~ MObserved (act MTime MAction E) (deadline MTime MAction E) ->
    Mle (deadline MTime MAction E) t ->
    ~ MObserved (act MTime MAction E) t.
Proof. unfold MObserved; auto. Qed.

(* Something is observed: the model is not the empty one. *)
Lemma m_nonvacuous : MObserved true 0.
Proof. reflexivity. Qed.

End Model.
