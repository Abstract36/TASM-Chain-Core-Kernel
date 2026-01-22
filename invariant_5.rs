#[test]
fn kernel_survives_silence() {
    let mut k = Kernel::new();
    k.advance_time(1);
    k.advance_time(100);
    k.advance_time(1000);

    // No panic, no state corruption
    assert!(k.absences().is_empty());
}
