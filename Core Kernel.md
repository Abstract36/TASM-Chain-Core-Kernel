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

