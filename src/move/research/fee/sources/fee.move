module fee::fee {

    const E_6: u128 = 1_000_000;

    #[view]
    /// Calculate fee using formula, which may truncate due to integer division.
    /// Then calculate proceeds as different of volume and fee, to avoid truncation errors.
    public fun post_match(volume: u64, fee_rate: u16): (u64, u64) {
        // Will not overflow since fee_rate / E_6 < 1.
        let fee = ((fee_rate as u128) * (volume as u128) / E_6 as u64);
        let proceeds = volume - fee;
        (fee, proceeds)
    }

    #[view]
    /// Calculate fee using formula, which may truncate due to integer division.
    /// Then calculate volume as different of input and fee, to avoid truncation errors.
    public fun pre_match(input: u64, fee_rate: u16): (u64, u64) {
        // Will not overflow since fee_rate / (E_6 + fee_rate) < 1.
        let fee = ((fee_rate as u128) * (input as u128) / (E_6 + (fee_rate as u128)) as u64);
        let volume = input - fee;
        (fee, volume)
    }

}