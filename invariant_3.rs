proptest! {
    #[test]
    fn early_observation_prevents_absence(
        deadline in 10u64..1000,
        obs_time in 1u64..9,
    ) {
        let mut k = Kernel::new();

        let intent = Intent {
            id: [5u8; 32],
            action: [6u8; 32],
            deadline,
        };

        k.declare_intent(intent);
        k.observe_action(intent.action, obs_time);
        k.advance_time(deadline);

        prop_assert!(!k.absences().contains(&intent.id));
    }
}
