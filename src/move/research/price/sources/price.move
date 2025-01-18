module price::price {

    /// The largest power of 10 that can fit in a `u64`, as a `u128`.
    /// In Python: `f"{10 ** (math.floor(math.log10(2 ** 64 - 1))):_}"`
    const DEC_MAX_U64_AS: u128 = 10_000_000_000_000_000_000;
    /// The exponent of the largest power of 10 that can fit in a `u64`.
    /// In Python: `math.floor(math.log10(2 ** 64 - 1))`
    const EXP_MAX_U64: u32 = 19;
    /// The exponent of the largest power of 10 that can fit in a `u128`.
    /// In Python: `math.floor(math.log10(2 ** 128 - 1))`
    const EXP_MAX: u32 = 38;
    /// The largest `u128` value. In Python: `f"{2 ** 128 - 1:_}"`
    const MAX_U128: u128 = 340_282_366_920_938_463_463_374_607_431_768_211_455;
    /// The bias for the exponent of the canonical price encoding, which is the minimum exponent
    /// that can be represented when taken as a negative number.
    const EXPONENT_BIAS: u32 = 16;
    /// The maximum exponent that can be represented in the canonical price encoding.
    const EXPONENT_MAX: u32 = 15;
    /// Decimal conversion factor to convert normalized significand to canonical price encoding.
    const SIGNIFICAND_CONVERSION_SHIFT: u32 = 7;

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

    /// Base term is 0.
    const E_BASE_ZERO: u64 = 1;
    /// Logarithm of 0 is undefined.
    const E_LOG_0_UNDEFINED: u64 = 2;
    /// Price is too small to represent.
    const E_TOO_SMALL_TO_REPRESENT: u64 = 3;
    /// Price is too large to represent.
    const E_TOO_LARGE_TO_REPRESENT: u64 = 4;

    #[view]
    /// Return the canonical price encoding for a given ratio of base and quote.
    public fun price(base: u64, quote: u64): u32 {
        assert!(base > 0, E_BASE_ZERO);

        let ratio_scaled = ((quote as u128) * DEC_MAX_U64_AS) / (base as u128);
        let (log_10_ratio_scaled, last_power_of_10_scaled) =
            floored_log_10_with_power(ratio_scaled);

        // The base-10 logarithm of the ratio must be at least the minimum allowable exponent after
        // scaling back down:
        //
        // log_10_ratio_scaled - EXP_MAX_U64 >= -EXPONENT_BIAS
        //
        // However to avoid underflowing the assertion, this must be rewritten as follows:
        assert!(
            log_10_ratio_scaled >= EXP_MAX_U64 - EXPONENT_BIAS,
            E_TOO_SMALL_TO_REPRESENT
        );

        // At this point, ratio_scaled could be as small as E_3 = 1_000, which scales back down
        // to 1_000 * 10^-19 = 1 * 10^-16, which is the smallest value that can be represented.
        // Hence extracting the significand may require padding or truncating. If less than
        // E_7, will need to pad, and if greater than E_7, will need to truncate. If
        // truncating, can divide by (last_power_of_10_scaled / E_7) to get the significand.
        //
        // In either case, the encoded exponent must be corrected for the shift amount.
        let (significand_encoded, exponent_encoded) =
            if (last_power_of_10_scaled < E_7) { // 3 <= n < 7.
                let (pad_multiplier, exponent_shift) =
                    if (last_power_of_10_scaled < E_5) { // 3 <= n < 5.
                        if (last_power_of_10_scaled < E_4) { // 3 <= n < 4.
                            (E_4, 4)
                        } else { // 4 <= n < 5.
                            (E_3, 3)
                        }
                    } else { // 5 <= n < 7.
                        if (last_power_of_10_scaled < E_6) { // 5 <= n < 6.
                            (E_2, 2)
                        } else { // 6 <= n < 7.
                            (E_1, 1)
                        }
                    };
                ((ratio_scaled * pad_multiplier),
                log_10_ratio_scaled + exponent_shift + EXPONENT_BIAS
                    - SIGNIFICAND_CONVERSION_SHIFT)
            } else {
                (ratio_scaled / (last_power_of_10_scaled / E_7), 42)
            };
        1
    }

    #[view]
    /// Returns the floored base-10 logarithm of `value`, and 10 raised to that power.
    ///
    /// The algorithm uses a binary search for speed, with each new branch of the search bisecting
    /// the remaining range of possible values.
    ///
    /// Since the largest power of then that can fit in a `u128` is `10^38`, the search range begins
    /// as `0 <= n < 39`. Then the search range is bisected about the floored average of the
    /// endpoints: `(0 + 39) / 2 = 19`. This process yields two branches: `0 <= n < 19` and
    /// `19 <= n < 39`. The bisection process is repeated until the range is narrowed to a single
    /// value, terminating the search.
    public fun floored_log_10_with_power(value: u128): (u32, u128) {
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

    #[test_only]
    fun assert_floored_log_10_with_power(
        value: u128, expected_log: u32, expected_power: u128
    ) {
        let (log, power) = floored_log_10_with_power(value);
        assert!(log == expected_log);
        assert!(power == expected_power);
    }

    #[test]
    fun test_floored_log_10_with_power() {
        // Test all powers of 10.
        assert_floored_log_10_with_power(E_0, N_0, E_0);
        assert_floored_log_10_with_power(E_1, N_1, E_1);
        assert_floored_log_10_with_power(E_2, N_2, E_2);
        assert_floored_log_10_with_power(E_3, N_3, E_3);
        assert_floored_log_10_with_power(E_4, N_4, E_4);
        assert_floored_log_10_with_power(E_5, N_5, E_5);
        assert_floored_log_10_with_power(E_6, N_6, E_6);
        assert_floored_log_10_with_power(E_7, N_7, E_7);
        assert_floored_log_10_with_power(E_8, N_8, E_8);
        assert_floored_log_10_with_power(E_9, N_9, E_9);
        assert_floored_log_10_with_power(E_10, N_10, E_10);
        assert_floored_log_10_with_power(E_11, N_11, E_11);
        assert_floored_log_10_with_power(E_12, N_12, E_12);
        assert_floored_log_10_with_power(E_13, N_13, E_13);
        assert_floored_log_10_with_power(E_14, N_14, E_14);
        assert_floored_log_10_with_power(E_15, N_15, E_15);
        assert_floored_log_10_with_power(E_16, N_16, E_16);
        assert_floored_log_10_with_power(E_17, N_17, E_17);
        assert_floored_log_10_with_power(E_18, N_18, E_18);
        assert_floored_log_10_with_power(E_19, N_19, E_19);
        assert_floored_log_10_with_power(E_20, N_20, E_20);
        assert_floored_log_10_with_power(E_21, N_21, E_21);
        assert_floored_log_10_with_power(E_22, N_22, E_22);
        assert_floored_log_10_with_power(E_23, N_23, E_23);
        assert_floored_log_10_with_power(E_24, N_24, E_24);
        assert_floored_log_10_with_power(E_25, N_25, E_25);
        assert_floored_log_10_with_power(E_26, N_26, E_26);
        assert_floored_log_10_with_power(E_27, N_27, E_27);
        assert_floored_log_10_with_power(E_28, N_28, E_28);
        assert_floored_log_10_with_power(E_29, N_29, E_29);
        assert_floored_log_10_with_power(E_30, N_30, E_30);
        assert_floored_log_10_with_power(E_31, N_31, E_31);
        assert_floored_log_10_with_power(E_32, N_32, E_32);
        assert_floored_log_10_with_power(E_33, N_33, E_33);
        assert_floored_log_10_with_power(E_34, N_34, E_34);
        assert_floored_log_10_with_power(E_35, N_35, E_35);
        assert_floored_log_10_with_power(E_36, N_36, E_36);
        assert_floored_log_10_with_power(E_37, N_37, E_37);
        assert_floored_log_10_with_power(E_38, N_38, E_38);

        // Test one more than each power of 10.
        assert_floored_log_10_with_power(E_0 + 1, N_0, E_0);
        assert_floored_log_10_with_power(E_1 + 1, N_1, E_1);
        assert_floored_log_10_with_power(E_2 + 1, N_2, E_2);
        assert_floored_log_10_with_power(E_3 + 1, N_3, E_3);
        assert_floored_log_10_with_power(E_4 + 1, N_4, E_4);
        assert_floored_log_10_with_power(E_5 + 1, N_5, E_5);
        assert_floored_log_10_with_power(E_6 + 1, N_6, E_6);
        assert_floored_log_10_with_power(E_7 + 1, N_7, E_7);
        assert_floored_log_10_with_power(E_8 + 1, N_8, E_8);
        assert_floored_log_10_with_power(E_9 + 1, N_9, E_9);
        assert_floored_log_10_with_power(E_10 + 1, N_10, E_10);
        assert_floored_log_10_with_power(E_11 + 1, N_11, E_11);
        assert_floored_log_10_with_power(E_12 + 1, N_12, E_12);
        assert_floored_log_10_with_power(E_13 + 1, N_13, E_13);
        assert_floored_log_10_with_power(E_14 + 1, N_14, E_14);
        assert_floored_log_10_with_power(E_15 + 1, N_15, E_15);
        assert_floored_log_10_with_power(E_16 + 1, N_16, E_16);
        assert_floored_log_10_with_power(E_17 + 1, N_17, E_17);
        assert_floored_log_10_with_power(E_18 + 1, N_18, E_18);
        assert_floored_log_10_with_power(E_19 + 1, N_19, E_19);
        assert_floored_log_10_with_power(E_20 + 1, N_20, E_20);
        assert_floored_log_10_with_power(E_21 + 1, N_21, E_21);
        assert_floored_log_10_with_power(E_22 + 1, N_22, E_22);
        assert_floored_log_10_with_power(E_23 + 1, N_23, E_23);
        assert_floored_log_10_with_power(E_24 + 1, N_24, E_24);
        assert_floored_log_10_with_power(E_25 + 1, N_25, E_25);
        assert_floored_log_10_with_power(E_26 + 1, N_26, E_26);
        assert_floored_log_10_with_power(E_27 + 1, N_27, E_27);
        assert_floored_log_10_with_power(E_28 + 1, N_28, E_28);
        assert_floored_log_10_with_power(E_29 + 1, N_29, E_29);
        assert_floored_log_10_with_power(E_30 + 1, N_30, E_30);
        assert_floored_log_10_with_power(E_31 + 1, N_31, E_31);
        assert_floored_log_10_with_power(E_32 + 1, N_32, E_32);
        assert_floored_log_10_with_power(E_33 + 1, N_33, E_33);
        assert_floored_log_10_with_power(E_34 + 1, N_34, E_34);
        assert_floored_log_10_with_power(E_35 + 1, N_35, E_35);
        assert_floored_log_10_with_power(E_36 + 1, N_36, E_36);
        assert_floored_log_10_with_power(E_37 + 1, N_37, E_37);
        assert_floored_log_10_with_power(E_38 + 1, N_38, E_38);

        // Test one less than each power of 10.
        assert_floored_log_10_with_power(E_1 - 1, N_0, E_0);
        assert_floored_log_10_with_power(E_2 - 1, N_1, E_1);
        assert_floored_log_10_with_power(E_3 - 1, N_2, E_2);
        assert_floored_log_10_with_power(E_4 - 1, N_3, E_3);
        assert_floored_log_10_with_power(E_5 - 1, N_4, E_4);
        assert_floored_log_10_with_power(E_6 - 1, N_5, E_5);
        assert_floored_log_10_with_power(E_7 - 1, N_6, E_6);
        assert_floored_log_10_with_power(E_8 - 1, N_7, E_7);
        assert_floored_log_10_with_power(E_9 - 1, N_8, E_8);
        assert_floored_log_10_with_power(E_10 - 1, N_9, E_9);
        assert_floored_log_10_with_power(E_11 - 1, N_10, E_10);
        assert_floored_log_10_with_power(E_12 - 1, N_11, E_11);
        assert_floored_log_10_with_power(E_13 - 1, N_12, E_12);
        assert_floored_log_10_with_power(E_14 - 1, N_13, E_13);
        assert_floored_log_10_with_power(E_15 - 1, N_14, E_14);
        assert_floored_log_10_with_power(E_16 - 1, N_15, E_15);
        assert_floored_log_10_with_power(E_17 - 1, N_16, E_16);
        assert_floored_log_10_with_power(E_18 - 1, N_17, E_17);
        assert_floored_log_10_with_power(E_19 - 1, N_18, E_18);
        assert_floored_log_10_with_power(E_20 - 1, N_19, E_19);
        assert_floored_log_10_with_power(E_21 - 1, N_20, E_20);
        assert_floored_log_10_with_power(E_22 - 1, N_21, E_21);
        assert_floored_log_10_with_power(E_23 - 1, N_22, E_22);
        assert_floored_log_10_with_power(E_24 - 1, N_23, E_23);
        assert_floored_log_10_with_power(E_25 - 1, N_24, E_24);
        assert_floored_log_10_with_power(E_26 - 1, N_25, E_25);
        assert_floored_log_10_with_power(E_27 - 1, N_26, E_26);
        assert_floored_log_10_with_power(E_28 - 1, N_27, E_27);
        assert_floored_log_10_with_power(E_29 - 1, N_28, E_28);
        assert_floored_log_10_with_power(E_30 - 1, N_29, E_29);
        assert_floored_log_10_with_power(E_31 - 1, N_30, E_30);
        assert_floored_log_10_with_power(E_32 - 1, N_31, E_31);
        assert_floored_log_10_with_power(E_33 - 1, N_32, E_32);
        assert_floored_log_10_with_power(E_34 - 1, N_33, E_33);
        assert_floored_log_10_with_power(E_35 - 1, N_34, E_34);
        assert_floored_log_10_with_power(E_36 - 1, N_35, E_35);
        assert_floored_log_10_with_power(E_37 - 1, N_36, E_36);
        assert_floored_log_10_with_power(E_38 - 1, N_37, E_37);

        // Test max value that can fit in a `u128`.
        assert_floored_log_10_with_power(MAX_U128, N_38, E_38);
    }
}
