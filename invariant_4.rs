#[test]
#[should_panic]
fn late_action_panics() {
    let mut k = Kernel::new();

    let intent = Intent {
        id: [7u8; 32],
        action: [8u8; 32],
        deadline: 10,
    };

    k.declare_intent(intent);
    k.observe_action(intent.action, 10); // == deadline → запрещено
}
