//! Time–Absence State Machines — executable kernel.
//!
//! The formal counterpart lives in `TASM.lean`. Each test in
//! `tests/invariants.rs` is the executable form of one of its theorems.
#![no_std]

extern crate alloc;

pub mod kernel;

pub use kernel::{ActionId, Intent, IntentId, Kernel, Time};
