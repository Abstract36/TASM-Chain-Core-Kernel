//! The five invariants, each the executable form of a theorem in `TASM.lean`.

use proptest::prelude::*;
use tasm_kernel::*;

fn intent(id: u8, action: u8, deadline: Time) -> Intent {
    Intent { id: [id; 32], action: [action; 32], deadline }
}

proptest! {
    /// Counterpart of `TASM.state_monotone`: the absence set only grows.
    #[test]
    fn absence_is_irreversible(t1 in 1u64..1000, dt in 1u64..1000) {
        let mut k = Kernel::new();
        k.declare_intent(intent(1, 2, t1));
        k.advance_time(t1);
        let before = k.absences().clone();
        k.advance_time(t1 + dt);
        prop_assert!(before.is_subset(k.absences()));
    }

    /// A deadline passing unobserved is what creates the absence.
    #[test]
    fn silence_creates_absence(deadline in 1u64..1000) {
        let mut k = Kernel::new();
        let e = intent(3, 4, deadline);
        k.declare_intent(e);
        k.advance_time(deadline);
        prop_assert!(k.absences().contains(&e.id));
    }

    /// Counterpart of the hypothesis of `TASM.no_late_action`: an action
    /// observed before its deadline never becomes an absence.
    #[test]
    fn early_observation_prevents_absence(deadline in 10u64..1000, obs in 1u64..9) {
        let mut k = Kernel::new();
        let e = intent(5, 6, deadline);
        k.declare_intent(e);
        k.observe_action(e.action, obs);
        k.advance_time(deadline);
        prop_assert!(!k.absences().contains(&e.id));
    }
}

/// Counterpart of `TASM.absence_closes_the_door`: the kernel refuses an
/// observation at or after the deadline rather than recording it.
#[test]
#[should_panic]
fn late_action_is_refused() {
    let mut k = Kernel::new();
    let e = intent(7, 8, 10);
    k.declare_intent(e);
    k.observe_action(e.action, 10);
}

/// Time may pass with nothing declared; the kernel stays consistent.
#[test]
fn kernel_survives_silence() {
    let mut k = Kernel::new();
    k.advance_time(1);
    k.advance_time(100);
    k.advance_time(1000);
    assert!(k.absences().is_empty());
}
