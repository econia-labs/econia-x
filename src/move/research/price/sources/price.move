module price::price {

    /// The largest `u128` value. In Python: `f"{int('1' * 128, 2):_}"`.
    const MAX_U128: u128 = 340_282_366_920_938_463_463_374_607_431_768_211_455;
    /// The largest `u64` value. In Python: `f"{int('1' * 64, 2):_}"`.
    const MAX_U64: u128 = 18_446_744_073_709_551_615;
    /// Number of bits to shift the exponent to the left in the canonical price encoding.
    const SHIFT_EXPONENT_BITS: u8 = 27;
    /// All bits set in integer of width required to encode significand.
    /// In Python: `hex(int('1' * 27, 2))`.
    const HI_SIGNIFICAND: u32 = 0x7ffffff;

    /// Special price zero.
    const P_ZERO: u32 = 0;
    /// Special price infinity, all bits set in `u32`. In Python: `hex(int('1' * 32, 2))`.
    const P_INFINITY: u32 = 0xffffffff;

    /// Maximum allowed significand for a regular price.
    const M_MAX: u32 = 99_999_999;
    /// Minimum allowed significand for a regular price. Same as `E_7` but as a `u32` for speed.
    const M_MIN: u32 = 10_000_000;

    const E_0: u128 = 1;
    const E_1: u128 = 10;
    const E_2: u128 = 100;
    const E_3: u128 = 1_000;
    const E_4: u128 = 10_000;
    const E_5: u128 = 100_000;
    const E_6: u128 = 1_000_000;
    const E_7: u128 = 10_000_000;
    const E_8: u128 = 100_000_000;
    const E_9: u128 = 1_000_000_000;
    const E_10: u128 = 10_000_000_000;
    const E_11: u128 = 100_000_000_000;
    const E_12: u128 = 1_000_000_000_000;
    const E_13: u128 = 10_000_000_000_000;
    const E_14: u128 = 100_000_000_000_000;
    const E_15: u128 = 1_000_000_000_000_000;
    const E_16: u128 = 10_000_000_000_000_000;
    const E_17: u128 = 100_000_000_000_000_000;
    const E_18: u128 = 1_000_000_000_000_000_000;
    const E_19: u128 = 10_000_000_000_000_000_000;
    const E_20: u128 = 100_000_000_000_000_000_000;
    const E_21: u128 = 1_000_000_000_000_000_000_000;
    const E_22: u128 = 10_000_000_000_000_000_000_000;
    const E_23: u128 = 100_000_000_000_000_000_000_000;
    const E_24: u128 = 1_000_000_000_000_000_000_000_000;
    const E_25: u128 = 10_000_000_000_000_000_000_000_000;
    const E_26: u128 = 100_000_000_000_000_000_000_000_000;
    const E_27: u128 = 1_000_000_000_000_000_000_000_000_000;
    const E_28: u128 = 10_000_000_000_000_000_000_000_000_000;
    const E_29: u128 = 100_000_000_000_000_000_000_000_000_000;
    const E_30: u128 = 1_000_000_000_000_000_000_000_000_000_000;
    const E_31: u128 = 10_000_000_000_000_000_000_000_000_000_000;
    const E_32: u128 = 100_000_000_000_000_000_000_000_000_000_000;
    const E_33: u128 = 1_000_000_000_000_000_000_000_000_000_000_000;
    const E_34: u128 = 10_000_000_000_000_000_000_000_000_000_000_000;
    const E_35: u128 = 100_000_000_000_000_000_000_000_000_000_000_000;
    const E_36: u128 = 1_000_000_000_000_000_000_000_000_000_000_000_000;
    const E_37: u128 = 10_000_000_000_000_000_000_000_000_000_000_000_000;
    const E_38: u128 = 100_000_000_000_000_000_000_000_000_000_000_000_000;

    const N_0: u32 = 0;
    const N_1: u32 = 1;
    const N_2: u32 = 2;
    const N_3: u32 = 3;
    const N_4: u32 = 4;
    const N_5: u32 = 5;
    const N_6: u32 = 6;
    const N_7: u32 = 7;
    const N_8: u32 = 8;
    const N_9: u32 = 9;
    const N_10: u32 = 10;
    const N_11: u32 = 11;
    const N_12: u32 = 12;
    const N_13: u32 = 13;
    const N_14: u32 = 14;
    const N_15: u32 = 15;
    const N_16: u32 = 16;
    const N_17: u32 = 17;
    const N_18: u32 = 18;
    const N_19: u32 = 19;
    const N_20: u32 = 20;
    const N_21: u32 = 21;
    const N_22: u32 = 22;
    const N_23: u32 = 23;
    const N_24: u32 = 24;
    const N_25: u32 = 25;
    const N_26: u32 = 26;
    const N_27: u32 = 27;
    const N_28: u32 = 28;
    const N_29: u32 = 29;
    const N_30: u32 = 30;
    const N_31: u32 = 31;
    const N_32: u32 = 32;
    const N_33: u32 = 33;
    const N_34: u32 = 34;
    const N_35: u32 = 35;
    const N_36: u32 = 36;
    const N_37: u32 = 37;
    const N_38: u32 = 38;

    /// Base argument is 0.
    const E_BASE_ZERO: u64 = 1;
    /// Logarithm of 0 is undefined.
    const E_LOG_0_UNDEFINED: u64 = 2;
    /// Price is too small to represent.
    const E_TOO_SMALL_TO_REPRESENT: u64 = 3;
    /// Price is too large to represent.
    const E_TOO_LARGE_TO_REPRESENT: u64 = 4;
    /// Price is invalid.
    const E_INVALID_PRICE: u64 = 5;
    /// Result overflows a `u64`.
    const E_OVERFLOW: u64 = 6;
    /// Exponent is not canonical.
    const E_INVALID_EXPONENT: u64 = 7;
    /// Positive exponent is not canonical.
    const E_INVALID_EXPONENT_POSITIVE: u64 = 8;
    /// Negative exponent is not canonical.
    const E_INVALID_EXPONENT_NEGATIVE: u64 = 9;
    /// Significand is too large.
    const E_INVALID_SIGNIFICAND_HI: u64 = 10;
    /// Significand is too small.
    const E_INVALID_SIGNIFICAND_LO: u64 = 11;

    #[view]
    public fun encoded_exponent(price: u32): u32 {
        price >> SHIFT_EXPONENT_BITS
    }

    #[view]
    public fun encoded_significand(price: u32): u32 {
        price & HI_SIGNIFICAND
    }

    #[view]
    /// Returns the floored base-10 logarithm of `value`, and 10 raised to that power (equal to the
    /// maximum power of 10 less than or equal to `value`).
    ///
    /// The algorithm uses a binary search for speed, with each new branch of the search bisecting
    /// the remaining range of possible values.
    ///
    /// Since the largest power of then that can fit in a `u128` is `10^38`, the search range begins
    /// as `0 <= n < 39`. Then the search range is bisected about the floored average of the
    /// endpoints: `(0 + 39) / 2 = 19`. This process yields two branches: `0 <= n < 19` and
    /// `19 <= n < 39`. The bisection process is repeated until the range is narrowed to a single
    /// value, terminating the search in `ceiling(log2(39)) = 6` iterations or less.
    public fun floored_log_10_with_max_power_leq(value: u128): (u32, u128) {
        assert!(value > 0, E_LOG_0_UNDEFINED);
        // 0 <= n < 39.
        if (value < E_19) { // 0 <= n < 19.
            if (value < E_9) { // 0 <= n < 9.
                if (value < E_4) { // 0 <= n < 4.
                    if (value < E_2) { // 0 <= n < 2.
                        if (value < E_1) { // 0 <= n < 1.
                            (N_0, E_0)
                        } else {
                            (N_1, E_1)
                        }
                    } else { // 2 <= n < 4.
                        if (value < E_3) { // 2 <= n < 3.
                            (N_2, E_2)
                        } else {
                            (N_3, E_3)
                        }
                    }
                } else { // 4 <= n < 9.
                    if (value < E_6) { // 4 <= n < 6.
                        if (value < E_5) { // 4 <= n < 5.
                            (N_4, E_4)
                        } else {
                            (N_5, E_5)
                        }
                    } else { // 6 <= n < 9.
                        if (value < E_7) { // 6 <= n < 7.
                            (N_6, E_6)
                        } else { // 7 <= n < 9.
                            if (value < E_8) { // 7 <= n < 8.
                                (N_7, E_7)
                            } else {
                                (N_8, E_8)
                            }
                        }
                    }
                }
            } else { // 9 <= n < 19.
                if (value < E_14) { // 9 <= n < 14.
                    if (value < E_11) { // 9 <= n < 11.
                        if (value < E_10) { // 9 <= n < 10.
                            (N_9, E_9)
                        } else {
                            (N_10, E_10)
                        }
                    } else { // 11 <= n < 14.
                        if (value < E_12) { // 11 <= n < 12.
                            (N_11, E_11)
                        } else {
                            if (value < E_13) { // 12 <= n < 13.
                                (N_12, E_12)
                            } else {
                                (N_13, E_13)
                            }
                        }
                    }
                } else { // 14 <= n < 19.
                    if (value < E_16) { // 14 <= n < 16.
                        if (value < E_15) { // 14 <= n < 15.
                            (N_14, E_14)
                        } else {
                            (N_15, E_15)
                        }
                    } else { // 16 <= n < 19.
                        if (value < E_17) { // 16 <= n < 17.
                            (N_16, E_16)
                        } else { // 17 <= n < 19.
                            if (value < E_18) { // 17 <= n < 18.
                                (N_17, E_17)
                            } else {
                                (N_18, E_18)
                            }
                        }
                    }
                }
            }
        } else { // 19 <= n < 39.
            if (value < E_29) { // 19 <= n < 29.
                if (value < E_24) { // 19 <= n < 24.
                    if (value < E_21) { // 19 <= n < 21.
                        if (value < E_20) { // 19 <= n < 20.
                            (N_19, E_19)
                        } else {
                            (N_20, E_20)
                        }
                    } else { // 21 <= n < 24.
                        if (value < E_22) { // 21 <= n < 22.
                            (N_21, E_21)
                        } else { // 22 <= n < 24.
                            if (value < E_23) { // 22 <= n < 23.
                                (N_22, E_22)
                            } else {
                                (N_23, E_23)
                            }
                        }
                    }
                } else { // 24 <= n < 29.
                    if (value < E_26) { // 24 <= n < 26.
                        if (value < E_25) { // 24 <= n < 25.
                            (N_24, E_24)
                        } else {
                            (N_25, E_25)
                        }
                    } else { // 26 <= n < 29.
                        if (value < E_27) { // 26 <= n < 27.
                            (N_26, E_26)
                        } else { // 27 <= n < 29.
                            if (value < E_28) { // 27 <= n < 28.
                                (N_27, E_27)
                            } else {
                                (N_28, E_28)
                            }
                        }
                    }
                }
            } else { // 29 <= n < 39.
                if (value < E_34) { // 29 <= n < 34.
                    if (value < E_31) { // 29 <= n < 31.
                        if (value < E_30) { // 29 <= n < 30.
                            (N_29, E_29)
                        } else {
                            (N_30, E_30)
                        }
                    } else { // 31 <= n < 34.
                        if (value < E_32) { // 31 <= n < 32.
                            (N_31, E_31)
                        } else { // 32 <= n < 34.
                            if (value < E_33) { // 32 <= n < 33.
                                (N_32, E_32)
                            } else {
                                (N_33, E_33)
                            }
                        }
                    }
                } else { // 34 <= n < 39.
                    if (value < E_36) { // 34 <= n < 36.
                        if (value < E_35) { // 34 <= n < 35.
                            (N_34, E_34)
                        } else {
                            (N_35, E_35)
                        }
                    } else { // 36 <= n < 39.
                        if (value < E_37) { // 36 <= n < 37.
                            (N_36, E_36)
                        } else { // 37 <= n < 39.
                            if (value < E_38) { // 37 <= n < 38.
                                (N_37, E_37)
                            } else {
                                (N_38, E_38)
                            }
                        }
                    }
                }
            }
        }
    }

    #[view]
    public fun infinity(): u32 {
        P_INFINITY
    }

    #[view]
    public fun is_canonical(price: u32): bool {
        is_regular(price) || is_special(price)
    }

    #[view]
    public fun is_infinity(price: u32): bool {
        price == P_INFINITY
    }

    #[view]
    public fun is_regular(price: u32): bool {
        let significand = encoded_significand(price);
        significand >= M_MIN && significand <= M_MAX
    }

    #[view]
    public fun is_special(price: u32): bool {
        is_infinity(price) || is_zero(price)
    }

    #[view]
    public fun is_zero(price: u32): bool {
        price == P_ZERO
    }

    #[view]
    public fun normalized_exponent_magnitude(price: u32): u32 {
        assert!(is_regular(price), E_INVALID_PRICE);
        let exponent = encoded_exponent(price);
        if (exponent > N_16) {
            exponent - N_16
        } else {
            N_16 - exponent
        }
    }

    #[view]
    public fun normalized_exponent_is_positive(price: u32): bool {
        assert!(is_regular(price), E_INVALID_PRICE);
        encoded_exponent(price) > N_16
    }

    #[view]
    /// Returns the power of 10 for a canonical exponent, using similar binary search as
    /// `floored_log_10_with_max_power_leq()`.
    public fun power_of_10(exponent: u32): u128 {
        assert!(exponent < N_17, E_INVALID_EXPONENT);
        // 0 <= n < 17.
        if (exponent < N_8) { // 0 <= n < 8.
            if (exponent < N_4) { // 0 <= n < 4.
                if (exponent < N_2) { // 0 <= n < 2.
                    if (exponent < N_1) { // 0 <= n < 1.
                        E_0
                    } else { E_1 }
                } else { // 2 <= n < 4.
                    if (exponent < N_3) { // 2 <= n < 3.
                        E_2
                    } else { E_3 }
                }
            } else { // 4 <= n < 8.
                if (exponent < N_6) { // 4 <= n < 6.
                    if (exponent < N_5) { // 4 <= n < 5.
                        E_4
                    } else { E_5 }
                } else { // 6 <= n < 8.
                    if (exponent < N_7) { // 6 <= n < 7.
                        E_6
                    } else { E_7 }
                }
            }
        } else { // 8 <= n < 17.
            if (exponent < N_12) { // 8 <= n < 12.
                if (exponent < N_10) { // 8 <= n < 10.
                    if (exponent < N_9) { // 8 <= n < 9.
                        E_8
                    } else { E_9 }
                } else { // 10 <= n < 12.
                    if (exponent < N_11) { // 10 <= n < 11.
                        E_10
                    } else { E_11 }
                }
            } else { // 12 <= n < 17.
                if (exponent < N_14) { // 12 <= n < 14.
                    if (exponent < N_13) { // 12 <= n < 13.
                        E_12
                    } else { E_13 }
                } else { // 14 <= n < 17.
                    if (exponent < N_15) { // 14 <= n < 15.
                        E_14
                    } else { // 15 <= n < 17.
                        if (exponent < N_16) { // 15 <= n < 16.
                            E_15
                        } else { E_16 }
                    }
                }
            }
        }
    }

    #[view]
    /// Return the canonical price encoding for a given ratio of base and quote.
    public fun price(base: u64, quote: u64): u32 {
        assert!(base > 0, E_BASE_ZERO);

        // Get the ratio of quote to base, scaling up by the maximum power of ten that can fit in a
        // `u64` (19), to avoid precision loss.
        let ratio_e19 = ((quote as u128) * E_19) / (base as u128);

        // Get the floored base-10 logarithm of the scaled ratio, and the maximum power of 10 less
        // than or equal to the scaled ratio.
        let (floored_log_10_ratio_e19, max_power_10_leq_ratio_e19) =
            floored_log_10_with_max_power_leq(ratio_e19);

        // The floored base-10 logarithm of the scaled ratio must be at least 3, because otherwise
        // the nominal price (once scaled back down) would have an exponent less than
        // `(3 - 19) = -16`, which is the smallest exponent that can be represented.
        assert!(floored_log_10_ratio_e19 >= N_3, E_TOO_SMALL_TO_REPRESENT);

        // The floored base-10 logarithm of the scaled ratio must be at most 34, because otherwise
        // the nominal price (once scaled back down) would have an exponent greater than
        //  `(34 - 19) = 15`, which is the largest exponent that can be represented.
        assert!(floored_log_10_ratio_e19 <= N_34, E_TOO_LARGE_TO_REPRESENT);

        // The encoded exponent is the floored base-10 logarithm of the scaled ratio, incremented
        // by the bias (16), then decremented by the maximum power of 10 that can fit in a `u64`
        // (19). This is equivalent to decrementing by 3.
        let exponent_encoded = floored_log_10_ratio_e19 - N_3;

        // If scaled ratio is smaller than `E_7`, it must be right-padded to yield a canonicalized
        // significand with 8 significant digits.
        let significand_encoded =
            if (ratio_e19 < E_7) {
                ratio_e19 * (E_7 / max_power_10_leq_ratio_e19)
            } else { // Otherwise it must be truncated to 8 significant digits.
                ratio_e19 / (max_power_10_leq_ratio_e19 / E_7)
            };

        (exponent_encoded << SHIFT_EXPONENT_BITS) | (significand_encoded as u32)
    }

    #[view]
    /// Encode terms into a regular price.
    ///
    /// `normalized_exponent_magnitude` of `0` can accept `exponent_is_positive` as `true` or
    /// `false`, even though `0` is technically not positive.
    public fun price_from_terms(
        significand_digits: u32,
        normalized_exponent_magnitude: u32,
        normalized_exponent_is_positive: bool
    ): u32 {
        // Encode bias.
        let encoded_exponent =
            if (normalized_exponent_is_positive) {
                assert!(
                    normalized_exponent_magnitude <= N_15, E_INVALID_EXPONENT_POSITIVE
                );
                N_16 + normalized_exponent_magnitude
            } else {
                assert!(
                    normalized_exponent_magnitude <= N_16, E_INVALID_EXPONENT_NEGATIVE
                );
                N_16 - normalized_exponent_magnitude
            };

        // Verify significand is in bounds.
        assert!(significand_digits <= M_MAX, E_INVALID_SIGNIFICAND_HI);
        assert!(significand_digits >= M_MIN, E_INVALID_SIGNIFICAND_LO);

        (encoded_exponent << SHIFT_EXPONENT_BITS) | significand_digits
    }

    #[view]
    public fun quote(base: u64, price: u32): u64 {

        // Check inputs, returning early for 0 result.
        let is_zero_price = is_zero(price);
        assert!(is_regular(price) || is_zero_price, E_INVALID_PRICE);
        if (is_zero_price || base == 0) return 0;

        // Extract inner values.
        let significand = encoded_significand(price);
        let exponent = encoded_exponent(price);

        // If the encoded exponent is less than the bias (16), then the normalized exponent is
        // negative and the result requires dividing by the corresponding power of 10. Otherwise,
        // the normalized exponent is positive and the result requires multiplying by the
        // corresponding power of 10.
        //
        // Since the encoded significand is 10^7 times the normalized significand, the final result
        // requires a division by `E_7` in either case.
        if (exponent < N_16) {
            exponent = N_16 - exponent; // Correct for bias.

            // Even if the intermediate multiplication overflows a `u64` into a `u128`, the final
            // result will not overflow a `u64` because a price with a negative exponent is
            // necessarily less than 1. That is, `power_of_10(exponent) * E_7` > significand`.
            ((base as u128) * (significand as u128) / (power_of_10(exponent) * E_7) as u64)

        } else { // The normalized exponent is positive.
            exponent -= N_16; // Correct for bias.

            // Consolidate division by `E_7` (the significand normalization operation) and
            // multiplication by the normalized exponent into one step. This avoids the need to cast
            // into a `u256`, which would be necessary if the division and multiplication were
            // performed in separate operations, because for example `MAX_U64 * M_MAX * 10^15`
            // overflows a `u128`. However `MAX_U64 * M_MAX * 10^8` (the worst case) does not.
            let result =
                if (exponent < N_7) {
                    (base as u128) * (significand as u128) / (power_of_10(N_7 - exponent))
                } else {
                    (base as u128) * (significand as u128) * (power_of_10(exponent - N_7))
                };

            // Check for overflow, return result.
            assert!(result <= MAX_U64, E_OVERFLOW);
            (result as u64)
        }
    }

    #[view]
    public fun zero(): u32 {
        P_ZERO
    }

    #[test_only]
    fun assert_floored_log_10_with_max_power_leq(
        value: u128, expected_log: u32, expected_power: u128
    ) {
        let (log, power) = floored_log_10_with_max_power_leq(value);
        assert!(log == expected_log);
        assert!(power == expected_power);
    }

    #[test]
    fun test_floored_log_10_with_max_power_leq() {
        // Test all powers of 10.
        assert_floored_log_10_with_max_power_leq(E_0, N_0, E_0);
        assert_floored_log_10_with_max_power_leq(E_1, N_1, E_1);
        assert_floored_log_10_with_max_power_leq(E_2, N_2, E_2);
        assert_floored_log_10_with_max_power_leq(E_3, N_3, E_3);
        assert_floored_log_10_with_max_power_leq(E_4, N_4, E_4);
        assert_floored_log_10_with_max_power_leq(E_5, N_5, E_5);
        assert_floored_log_10_with_max_power_leq(E_6, N_6, E_6);
        assert_floored_log_10_with_max_power_leq(E_7, N_7, E_7);
        assert_floored_log_10_with_max_power_leq(E_8, N_8, E_8);
        assert_floored_log_10_with_max_power_leq(E_9, N_9, E_9);
        assert_floored_log_10_with_max_power_leq(E_10, N_10, E_10);
        assert_floored_log_10_with_max_power_leq(E_11, N_11, E_11);
        assert_floored_log_10_with_max_power_leq(E_12, N_12, E_12);
        assert_floored_log_10_with_max_power_leq(E_13, N_13, E_13);
        assert_floored_log_10_with_max_power_leq(E_14, N_14, E_14);
        assert_floored_log_10_with_max_power_leq(E_15, N_15, E_15);
        assert_floored_log_10_with_max_power_leq(E_16, N_16, E_16);
        assert_floored_log_10_with_max_power_leq(E_17, N_17, E_17);
        assert_floored_log_10_with_max_power_leq(E_18, N_18, E_18);
        assert_floored_log_10_with_max_power_leq(E_19, N_19, E_19);
        assert_floored_log_10_with_max_power_leq(E_20, N_20, E_20);
        assert_floored_log_10_with_max_power_leq(E_21, N_21, E_21);
        assert_floored_log_10_with_max_power_leq(E_22, N_22, E_22);
        assert_floored_log_10_with_max_power_leq(E_23, N_23, E_23);
        assert_floored_log_10_with_max_power_leq(E_24, N_24, E_24);
        assert_floored_log_10_with_max_power_leq(E_25, N_25, E_25);
        assert_floored_log_10_with_max_power_leq(E_26, N_26, E_26);
        assert_floored_log_10_with_max_power_leq(E_27, N_27, E_27);
        assert_floored_log_10_with_max_power_leq(E_28, N_28, E_28);
        assert_floored_log_10_with_max_power_leq(E_29, N_29, E_29);
        assert_floored_log_10_with_max_power_leq(E_30, N_30, E_30);
        assert_floored_log_10_with_max_power_leq(E_31, N_31, E_31);
        assert_floored_log_10_with_max_power_leq(E_32, N_32, E_32);
        assert_floored_log_10_with_max_power_leq(E_33, N_33, E_33);
        assert_floored_log_10_with_max_power_leq(E_34, N_34, E_34);
        assert_floored_log_10_with_max_power_leq(E_35, N_35, E_35);
        assert_floored_log_10_with_max_power_leq(E_36, N_36, E_36);
        assert_floored_log_10_with_max_power_leq(E_37, N_37, E_37);
        assert_floored_log_10_with_max_power_leq(E_38, N_38, E_38);

        // Test one more than each power of 10.
        assert_floored_log_10_with_max_power_leq(E_0 + 1, N_0, E_0);
        assert_floored_log_10_with_max_power_leq(E_1 + 1, N_1, E_1);
        assert_floored_log_10_with_max_power_leq(E_2 + 1, N_2, E_2);
        assert_floored_log_10_with_max_power_leq(E_3 + 1, N_3, E_3);
        assert_floored_log_10_with_max_power_leq(E_4 + 1, N_4, E_4);
        assert_floored_log_10_with_max_power_leq(E_5 + 1, N_5, E_5);
        assert_floored_log_10_with_max_power_leq(E_6 + 1, N_6, E_6);
        assert_floored_log_10_with_max_power_leq(E_7 + 1, N_7, E_7);
        assert_floored_log_10_with_max_power_leq(E_8 + 1, N_8, E_8);
        assert_floored_log_10_with_max_power_leq(E_9 + 1, N_9, E_9);
        assert_floored_log_10_with_max_power_leq(E_10 + 1, N_10, E_10);
        assert_floored_log_10_with_max_power_leq(E_11 + 1, N_11, E_11);
        assert_floored_log_10_with_max_power_leq(E_12 + 1, N_12, E_12);
        assert_floored_log_10_with_max_power_leq(E_13 + 1, N_13, E_13);
        assert_floored_log_10_with_max_power_leq(E_14 + 1, N_14, E_14);
        assert_floored_log_10_with_max_power_leq(E_15 + 1, N_15, E_15);
        assert_floored_log_10_with_max_power_leq(E_16 + 1, N_16, E_16);
        assert_floored_log_10_with_max_power_leq(E_17 + 1, N_17, E_17);
        assert_floored_log_10_with_max_power_leq(E_18 + 1, N_18, E_18);
        assert_floored_log_10_with_max_power_leq(E_19 + 1, N_19, E_19);
        assert_floored_log_10_with_max_power_leq(E_20 + 1, N_20, E_20);
        assert_floored_log_10_with_max_power_leq(E_21 + 1, N_21, E_21);
        assert_floored_log_10_with_max_power_leq(E_22 + 1, N_22, E_22);
        assert_floored_log_10_with_max_power_leq(E_23 + 1, N_23, E_23);
        assert_floored_log_10_with_max_power_leq(E_24 + 1, N_24, E_24);
        assert_floored_log_10_with_max_power_leq(E_25 + 1, N_25, E_25);
        assert_floored_log_10_with_max_power_leq(E_26 + 1, N_26, E_26);
        assert_floored_log_10_with_max_power_leq(E_27 + 1, N_27, E_27);
        assert_floored_log_10_with_max_power_leq(E_28 + 1, N_28, E_28);
        assert_floored_log_10_with_max_power_leq(E_29 + 1, N_29, E_29);
        assert_floored_log_10_with_max_power_leq(E_30 + 1, N_30, E_30);
        assert_floored_log_10_with_max_power_leq(E_31 + 1, N_31, E_31);
        assert_floored_log_10_with_max_power_leq(E_32 + 1, N_32, E_32);
        assert_floored_log_10_with_max_power_leq(E_33 + 1, N_33, E_33);
        assert_floored_log_10_with_max_power_leq(E_34 + 1, N_34, E_34);
        assert_floored_log_10_with_max_power_leq(E_35 + 1, N_35, E_35);
        assert_floored_log_10_with_max_power_leq(E_36 + 1, N_36, E_36);
        assert_floored_log_10_with_max_power_leq(E_37 + 1, N_37, E_37);
        assert_floored_log_10_with_max_power_leq(E_38 + 1, N_38, E_38);

        // Test one less than each power of 10.
        assert_floored_log_10_with_max_power_leq(E_1 - 1, N_0, E_0);
        assert_floored_log_10_with_max_power_leq(E_2 - 1, N_1, E_1);
        assert_floored_log_10_with_max_power_leq(E_3 - 1, N_2, E_2);
        assert_floored_log_10_with_max_power_leq(E_4 - 1, N_3, E_3);
        assert_floored_log_10_with_max_power_leq(E_5 - 1, N_4, E_4);
        assert_floored_log_10_with_max_power_leq(E_6 - 1, N_5, E_5);
        assert_floored_log_10_with_max_power_leq(E_7 - 1, N_6, E_6);
        assert_floored_log_10_with_max_power_leq(E_8 - 1, N_7, E_7);
        assert_floored_log_10_with_max_power_leq(E_9 - 1, N_8, E_8);
        assert_floored_log_10_with_max_power_leq(E_10 - 1, N_9, E_9);
        assert_floored_log_10_with_max_power_leq(E_11 - 1, N_10, E_10);
        assert_floored_log_10_with_max_power_leq(E_12 - 1, N_11, E_11);
        assert_floored_log_10_with_max_power_leq(E_13 - 1, N_12, E_12);
        assert_floored_log_10_with_max_power_leq(E_14 - 1, N_13, E_13);
        assert_floored_log_10_with_max_power_leq(E_15 - 1, N_14, E_14);
        assert_floored_log_10_with_max_power_leq(E_16 - 1, N_15, E_15);
        assert_floored_log_10_with_max_power_leq(E_17 - 1, N_16, E_16);
        assert_floored_log_10_with_max_power_leq(E_18 - 1, N_17, E_17);
        assert_floored_log_10_with_max_power_leq(E_19 - 1, N_18, E_18);
        assert_floored_log_10_with_max_power_leq(E_20 - 1, N_19, E_19);
        assert_floored_log_10_with_max_power_leq(E_21 - 1, N_20, E_20);
        assert_floored_log_10_with_max_power_leq(E_22 - 1, N_21, E_21);
        assert_floored_log_10_with_max_power_leq(E_23 - 1, N_22, E_22);
        assert_floored_log_10_with_max_power_leq(E_24 - 1, N_23, E_23);
        assert_floored_log_10_with_max_power_leq(E_25 - 1, N_24, E_24);
        assert_floored_log_10_with_max_power_leq(E_26 - 1, N_25, E_25);
        assert_floored_log_10_with_max_power_leq(E_27 - 1, N_26, E_26);
        assert_floored_log_10_with_max_power_leq(E_28 - 1, N_27, E_27);
        assert_floored_log_10_with_max_power_leq(E_29 - 1, N_28, E_28);
        assert_floored_log_10_with_max_power_leq(E_30 - 1, N_29, E_29);
        assert_floored_log_10_with_max_power_leq(E_31 - 1, N_30, E_30);
        assert_floored_log_10_with_max_power_leq(E_32 - 1, N_31, E_31);
        assert_floored_log_10_with_max_power_leq(E_33 - 1, N_32, E_32);
        assert_floored_log_10_with_max_power_leq(E_34 - 1, N_33, E_33);
        assert_floored_log_10_with_max_power_leq(E_35 - 1, N_34, E_34);
        assert_floored_log_10_with_max_power_leq(E_36 - 1, N_35, E_35);
        assert_floored_log_10_with_max_power_leq(E_37 - 1, N_36, E_36);
        assert_floored_log_10_with_max_power_leq(E_38 - 1, N_37, E_37);

        // Test max value that can fit in a `u128`.
        assert_floored_log_10_with_max_power_leq(MAX_U128, N_38, E_38);
    }

    #[test]
    #[expected_failure(abort_code = E_LOG_0_UNDEFINED)]
    public fun test_floored_log_10_with_max_power_leq_log_0_undefined() {
        floored_log_10_with_max_power_leq(0);
    }

    #[test]
    public fun test_helpers() {
        // Infinity.
        assert!(infinity() == P_INFINITY);
        assert!(is_canonical(infinity()));
        assert!(is_infinity(infinity()));
        assert!(!is_regular(infinity()));
        assert!(is_special(infinity()));
        assert!(!is_zero(infinity()));

        // Zero.
        assert!(zero() == P_ZERO);
        assert!(is_canonical(zero()));
        assert!(!is_infinity(zero()));
        assert!(!is_regular(zero()));
        assert!(is_special(zero()));
        assert!(is_zero(zero()));

        // Regular.
        let price = price_from_terms((E_7 as u32), 0, false); // Price p = 1.
        assert!(is_canonical(price));
        assert!(!is_infinity(price));
        assert!(is_regular(price));
        assert!(!is_special(price));
        assert!(!is_zero(price));
    }

    #[test]
    #[expected_failure(abort_code = E_INVALID_PRICE)]
    public fun test_normlized_exponent_magnitude_invalid_price() {
        normalized_exponent_magnitude(infinity());
    }

    #[test]
    #[expected_failure(abort_code = E_INVALID_PRICE)]
    public fun test_normlized_exponent_is_positive_invalid_price() {
        normalized_exponent_is_positive(infinity());
    }

    #[test]
    public fun test_power_of_10() {
        assert!(power_of_10(N_0) == E_0);
        assert!(power_of_10(N_1) == E_1);
        assert!(power_of_10(N_2) == E_2);
        assert!(power_of_10(N_3) == E_3);
        assert!(power_of_10(N_4) == E_4);
        assert!(power_of_10(N_5) == E_5);
        assert!(power_of_10(N_6) == E_6);
        assert!(power_of_10(N_7) == E_7);
        assert!(power_of_10(N_8) == E_8);
        assert!(power_of_10(N_9) == E_9);
        assert!(power_of_10(N_10) == E_10);
        assert!(power_of_10(N_11) == E_11);
        assert!(power_of_10(N_12) == E_12);
        assert!(power_of_10(N_13) == E_13);
        assert!(power_of_10(N_14) == E_14);
        assert!(power_of_10(N_15) == E_15);
        assert!(power_of_10(N_16) == E_16);
    }

    #[test]
    #[expected_failure(abort_code = E_INVALID_EXPONENT)]
    public fun test_power_of_10_invalid_exponent() {
        power_of_10(N_17);
    }

    #[test]
    #[expected_failure(abort_code = E_BASE_ZERO)]
    public fun test_price_base_zero() {
        price(0, 1);
    }

    #[test]
    #[expected_failure(abort_code = E_INVALID_EXPONENT_NEGATIVE)]
    public fun test_price_from_terms_invalid_exponent_negative() {
        price_from_terms((E_7 as u32), N_17, false);
    }

    #[test]
    #[expected_failure(abort_code = E_INVALID_EXPONENT_POSITIVE)]
    public fun test_price_from_terms_invalid_exponent_positive() {
        price_from_terms((E_7 as u32), N_16, true);
    }

    #[test]
    #[expected_failure(abort_code = E_INVALID_SIGNIFICAND_HI)]
    public fun test_price_from_terms_invalid_significand_hi() {
        price_from_terms(M_MAX + 1, N_15, true);
    }

    #[test]
    #[expected_failure(abort_code = E_INVALID_SIGNIFICAND_LO)]
    public fun test_price_from_terms_invalid_significand_lo() {
        price_from_terms(M_MIN - 1, N_15, true);
    }

    #[test]
    #[expected_failure(abort_code = E_TOO_LARGE_TO_REPRESENT)]
    public fun test_price_too_large_to_represent() {
        // Price 9.9999999 * 10^16
        let base = 100;
        let quote = 9_999_999_900_000_000_000;
        price(base, quote);
    }

    #[test]
    #[expected_failure(abort_code = E_TOO_SMALL_TO_REPRESENT)]
    public fun test_price_too_small_to_represent() {
        // Price 1.0000000 * 10^-17
        let base = 2_000_000_000_000_000_000;
        let quote = 20;
        price(base, quote);
    }

    #[test]
    public fun test_prices_assorted() {
        // Price 1.25 * 10^7
        let base = 23_587;
        let quote = 294_837_500_000;
        let price = price(base, quote);
        let normalized_exponent_magnitude = 7;
        let normalized_exponent_is_positive = true;
        let significand_digits = 12_500_000;
        assert!(
            encoded_exponent(price) == N_16 + normalized_exponent_magnitude
        );
        assert!(encoded_significand(price) == significand_digits);
        assert!(quote(base, price) == quote);
        assert!(
            price_from_terms(
                significand_digits,
                normalized_exponent_magnitude,
                normalized_exponent_is_positive
            ) == price
        );
        assert!(normalized_exponent_magnitude(price) == normalized_exponent_magnitude);
        assert!(
            normalized_exponent_is_positive(price) == normalized_exponent_is_positive
        );

        // Price 8.7654321 * 10^-12
        base = 10_000_000_000_000_000_000;
        quote = 87_654_321;
        price = price(base, quote);
        normalized_exponent_magnitude = 12;
        normalized_exponent_is_positive = false;
        significand_digits = 87_654_321;
        assert!(
            encoded_exponent(price) == N_16 - normalized_exponent_magnitude
        );
        assert!(encoded_significand(price) == significand_digits);
        assert!(quote(base, price) == quote);
        assert!(
            price_from_terms(
                significand_digits,
                normalized_exponent_magnitude,
                normalized_exponent_is_positive
            ) == price
        );
        assert!(normalized_exponent_magnitude(price) == normalized_exponent_magnitude);
        assert!(
            normalized_exponent_is_positive(price) == normalized_exponent_is_positive
        );

        // Price 5.0000000 * 10^-16
        base = 2_000_000_000_000_000_000;
        quote = 1_000;
        price = price(base, quote);
        normalized_exponent_magnitude = 16;
        normalized_exponent_is_positive = false;
        significand_digits = 50_000_000;
        assert!(
            encoded_exponent(price) == N_16 - normalized_exponent_magnitude
        );
        assert!(encoded_significand(price) == significand_digits);
        assert!(quote(base, price) == quote);
        assert!(
            price_from_terms(
                significand_digits,
                normalized_exponent_magnitude,
                normalized_exponent_is_positive
            ) == price
        );
        assert!(normalized_exponent_magnitude(price) == normalized_exponent_magnitude);
        assert!(
            normalized_exponent_is_positive(price) == normalized_exponent_is_positive
        );

        // Price 9.9999999 * 10^15
        base = 1_000;
        quote = 9_999_999_900_000_000_000;
        price = price(base, quote);
        normalized_exponent_magnitude = 15;
        normalized_exponent_is_positive = true;
        significand_digits = 99_999_999;
        assert!(encoded_exponent(price) == N_16 + 15);
        assert!(encoded_significand(price) == significand_digits);
        assert!(quote(base, price) == quote);
        assert!(
            price_from_terms(
                significand_digits,
                normalized_exponent_magnitude,
                normalized_exponent_is_positive
            ) == price
        );
        assert!(normalized_exponent_magnitude(price) == normalized_exponent_magnitude);
        assert!(
            normalized_exponent_is_positive(price) == normalized_exponent_is_positive
        );

        // Price 1.0000000 * 10^-16
        base = 2_000_000_000_000_000_000;
        quote = 200;
        price = price(base, quote);
        normalized_exponent_magnitude = 16;
        normalized_exponent_is_positive = false;
        significand_digits = 10_000_000;
        assert!(
            encoded_exponent(price) == N_16 - normalized_exponent_magnitude
        );
        assert!(encoded_significand(price) == significand_digits);
        assert!(quote(base, price) == quote);
        assert!(
            price_from_terms(
                significand_digits,
                normalized_exponent_magnitude,
                normalized_exponent_is_positive
            ) == price
        );
        assert!(normalized_exponent_magnitude(price) == normalized_exponent_magnitude);
        assert!(
            normalized_exponent_is_positive(price) == normalized_exponent_is_positive
        );

        // Price 9.7900000 * 10^1
        base = 2_000_000;
        quote = 195_800_000;
        price = price(base, quote);
        normalized_exponent_magnitude = 1;
        normalized_exponent_is_positive = true;
        significand_digits = 97_900_000;
        assert!(
            encoded_exponent(price) == N_16 + normalized_exponent_magnitude
        );
        assert!(encoded_significand(price) == significand_digits);
        assert!(quote(base, price) == quote);
        assert!(
            price_from_terms(
                significand_digits,
                normalized_exponent_magnitude,
                normalized_exponent_is_positive
            ) == price
        );
        assert!(normalized_exponent_magnitude(price) == normalized_exponent_magnitude);
        assert!(
            normalized_exponent_is_positive(price) == normalized_exponent_is_positive
        );

    }

    #[test]
    public fun test_quote_early_returns() {
        // Price is zero.
        let price = zero();
        let base = 1;
        assert!(quote(base, price) == 0);

        // Base is zero.
        let quote = 25;
        price = price(base, quote);
        base = 0;
        assert!(quote(base, price) == 0);
    }

    #[test]
    #[expected_failure(abort_code = E_INVALID_PRICE)]
    public fun test_quote_invalid_price() {
        let price = infinity();
        let base = 4;
        quote(base, price);
    }

    #[test]
    #[expected_failure(abort_code = E_OVERFLOW)]
    public fun test_quote_overflow() {
        let price = price(100, 101);
        let base = (MAX_U64 as u64);
        quote(base, price);
    }
}
