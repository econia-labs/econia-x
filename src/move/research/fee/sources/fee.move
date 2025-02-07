module fee::fee {

    const E_6: u128 = 1_000_000;

    #[view]
    /// Calculate fee using formula, which may truncate due to integer division.
    /// Then calculate proceeds as difference of volume and fee, to avoid truncation errors.
    public fun post_match(volume: u64, fee_rate: u16): (u64, u64) {
        // Will not overflow since fee_rate / E_6 < 1.
        let fee = ((fee_rate as u128) * (volume as u128) / E_6 as u64);
        let output = volume - fee;
        (fee, output)
    }

    #[view]
    /// Calculate fee using formula, which may truncate due to integer division.
    /// Then calculate volume as difference of input and fee, to avoid truncation errors.
    public fun pre_match(input: u64, fee_rate: u16): (u64, u64) {
        // Will not overflow since fee_rate / (E_6 + fee_rate) < 1.
        let fee = ((fee_rate as u128) * (input as u128) / (E_6 + (fee_rate as u128)) as u64);
        let volume = input - fee;
        (fee, volume)
    }

    #[test]
    public fun test_derivation_examples() {
        let (fee, output) = post_match(40_000, 5_000);
        assert!(fee == 200);
        assert!(output == 39_800);
        (fee, output) = post_match(40_000, 0);
        assert!(fee == 0);
        assert!(output == 40_000);

        let (fee, volume) = pre_match(20_300, 15_000);
        assert!(fee == 300);
        assert!(volume == 20_000);
        (fee, volume) = pre_match(20_300, 0);
        assert!(fee == 0);
        assert!(volume == 20_300);
    }
}
