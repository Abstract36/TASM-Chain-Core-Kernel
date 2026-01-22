use proptest::prelude::*;
use crate::kernel::*;

proptest! {
    #[test]
    fn absence_is_irreversible(
        t1 in 1u64..1000,
        dt in 1u64..1000,
    ) {
        let mut k = Kernel::new();

        let intent = Intent {
            id: [1u8; 32],
            action: [2u8; 32],
            deadline: t1,
        };

        k.declare_intent(intent);
        k.advance_time(t1);

        let abs_at_t1 = k.absences().clone();

        k.advance_time(t1 + dt);
        let abs_later = k.absences();

        // monotonic growth
        prop_assert!(abs_at_t1.is_subset(abs_later));
    }
}
