proptest! {
    #[test]
    fn silence_creates_absence(deadline in 1u64..1000) {
        let mut k = Kernel::new();

        let intent = Intent {
            id: [3u8; 32],
            action: [4u8; 32],
            deadline,
        };

        k.declare_intent(intent);
        k.advance_time(deadline);

        prop_assert!(k.absences().contains(&intent.id));
    }
}
