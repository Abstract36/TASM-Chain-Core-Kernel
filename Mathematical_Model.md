# TASM-Chain — Mathematical Model

This document defines the **formal mathematical model**
underlying TASM-Chain.

It is self-contained.
It does not depend on implementation details.
It does not assume a running network.

The purpose of this document is to prove that the kernel
is derived from a coherent and closed formal system.

---

## 1. Universe of Discourse

### Time

Let  
\[
\mathbb{T} = \{t_0, t_1, t_2, \dots\}
\]
be a non-empty set equipped with a relation \( \leq \).

**Axioms of Time**

1. **Linearity**
\[
\forall t_1, t_2 \in \mathbb{T}:\quad
t_1 \le t_2 \;\lor\; t_2 \le t_1
\]

2. **Transitivity**
\[
t_1 \le t_2 \land t_2 \le t_3
\;\Rightarrow\;
t_1 \le t_3
\]

3. **Irreversibility**
There exists no operation that makes
\( t_2 < t_1 \) once \( t_1 \le t_2 \).

Time is treated as a primitive source of truth.

---

## 2. Actions and Intents

### Actions

Let  
\[
\mathcal{A} \neq \varnothing
\]
be a set of formalisable actions.

No structure is assumed on \( \mathcal{A} \).

---

### Intents

An **Intent** is defined as an ordered pair:
\[
E := (a, T)
\]
where:
- \( a \in \mathcal{A} \) is an action
- \( T \in \mathbb{T} \) is a deadline

An intent does not imply execution.
It only introduces a future point of evaluation.

---

## 3. Observation Predicate

Define a predicate:
\[
\mathrm{Obs}(a, t)
\]
read as:

> action \(a\) was observed no later than time \(t\)

**Monotonicity Axiom**
\[
\mathrm{Obs}(a, t_1) \land t_1 \le t_2
\;\Rightarrow\;
\mathrm{Obs}(a, t_2)
\]

Observation is optional.
The model remains valid if no observations exist.

---

## 4. Absence Definition

### Absence Predicate

For an intent \( E = (a, T) \) and time \( t \):

\[
\mathrm{Abs}(E, t)
\;\stackrel{\mathrm{def}}{=}\;
(T \le t) \land \neg \mathrm{Obs}(a, T)
\]

**Interpretation**

Absence is:
- not an event
- not a transition
- not a stored record

It is a logical consequence of time.

---

## 5. Prohibition of Late Action

**Axiom (No Late Action)**

\[
T \le t
\;\Rightarrow\;
\neg \mathrm{Obs}(a, t)
\]

This axiom forbids worlds in which an action
is observed after its deadline.

It is a logical restriction, not an execution rule.

---

## 6. System State

### State Definition

For any time \( t \):

\[
\mathcal{S}(t) :=
\{ E \mid \mathrm{Abs}(E, t) \}
\]

The system state is the set of all intents
whose absence has become true by time \(t\).

---

## 7. Fundamental Properties

### Lemma 1 — Absence Non-Contradiction
\[
\forall E,t:\quad
\neg (\mathrm{Abs}(E,t) \land \neg \mathrm{Abs}(E,t))
\]

---

### Lemma 2 — Absence Irreversibility
\[
\mathrm{Abs}(E,t_1) \land t_1 \le t_2
\;\Rightarrow\;
\mathrm{Abs}(E,t_2)
\]

---

### Lemma 3 — No Retroactive Observation
\[
\mathrm{Abs}(E,t)
\;\Rightarrow\;
\neg \mathrm{Obs}(a,t)
\]

---

## 8. State Evolution

### Monotonicity of State

\[
t_1 \le t_2
\;\Rightarrow\;
\mathcal{S}(t_1) \subseteq \mathcal{S}(t_2)
\]

State evolution is monotonic and irreversible.

There are no state rollbacks.

---

## 9. Absence as the Only Transition

The system admits exactly one form of state change:

\[
\neg \mathrm{Obs}(a,T)
\;\land\;
T \le t
\;\Rightarrow\;
E \in \mathcal{S}(t)
\]

There is no dual rule that removes elements from state.

---

## 10. Consistency Theorem

### Theorem (Model Consistency)

There exists a structure  
\[
\langle \mathbb{T}, \mathcal{A}, \mathrm{Obs}, \mathrm{Abs} \rangle
\]
satisfying all axioms and definitions above
without logical contradiction.

**Implication**

The TASM-Chain kernel is a valid formal system,
independent of implementation or deployment.

---

## 11. What the Model Does Not Assume

The model does not assume:

- agents
- incentives
- execution semantics
- consensus mechanisms
- governance structures

These belong to other layers and are intentionally excluded.

---

## 12. Final Mathematical Statement

\[
\boxed{
\text{In TASM-Chain,}
\quad
\text{state is the accumulation of impossibilities}
\quad
\text{induced by time alone.}
}
\]

---

## 13. Closure

This mathematical model is complete.

Any extension that introduces:
- reversibility
- forgiveness
- execution-driven transitions

defines a different system.

The model ends here.
