module price::price {

    /// The largest power of 10 that can fit in a `u64`, as a `u128`.
    /// In Python: `f"{10 ** (math.floor(math.log10(2 ** 64 - 1))):_}"`
    const DEC_MAX_U64_AS_U128: u128 = 10_000_000_000_000_000_000;
    /// The exponent of the largest power of 10 that can fit in a `u64`.
    /// In Python: `math.floor(math.log10(2 ** 64 - 1))`
    const EXP_MAX_U64: u32 = 19;
    /// The exponent of the largest power of 10 that can fit in a `u128`.
    /// In Python: `math.floor(math.log10(2 ** 128 - 1))`
    const EXP_MAX_U128: u32 = 38;
    /// The largest `u128` value. In Python: `f"{2 ** 128 - 1:_}"`
    const U128_MAX: u128 = 340_282_366_920_938_463_463_374_607_431_768_211_455;
    /// The bias for the exponent of the canonical price encoding, which is the minimum exponent
    /// that can be represented when taken as a negative number.
    const EXPONENT_BIAS: u32 = 16;
    /// The maximum exponent that can be represented in the canonical price encoding.
    const EXPONENT_MAX: u32 = 15;
    /// Decimal conversion factor to convert normalized significand to canonical price encoding.
    const SIGNIFICAND_CONVERSION_SHIFT: u32 = 7;

    const E_0_U128: u128 = 1;
    const E_1_U128: u128 = 10;
    const E_2_U128: u128 = 100;
    const E_3_U128: u128 = 1_000;
    const E_4_U128: u128 = 10_000;
    const E_5_U128: u128 = 100_000;
    const E_6_U128: u128 = 1_000_000;
    const E_7_U128: u128 = 10_000_000;
    const E_8_U128: u128 = 100_000_000;
    const E_9_U128: u128 = 1_000_000_000;
    const E_10_U128: u128 = 10_000_000_000;
    const E_11_U128: u128 = 100_000_000_000;
    const E_12_U128: u128 = 1_000_000_000_000;
    const E_13_U128: u128 = 10_000_000_000_000;
    const E_14_U128: u128 = 100_000_000_000_000;
    const E_15_U128: u128 = 1_000_000_000_000_000;
    const E_16_U128: u128 = 10_000_000_000_000_000;
    const E_17_U128: u128 = 100_000_000_000_000_000;
    const E_18_U128: u128 = 1_000_000_000_000_000_000;
    const E_19_U128: u128 = 10_000_000_000_000_000_000;
    const E_20_U128: u128 = 100_000_000_000_000_000_000;
    const E_21_U128: u128 = 1_000_000_000_000_000_000_000;
    const E_22_U128: u128 = 10_000_000_000_000_000_000_000;
    const E_23_U128: u128 = 100_000_000_000_000_000_000_000;
    const E_24_U128: u128 = 1_000_000_000_000_000_000_000_000;
    const E_25_U128: u128 = 10_000_000_000_000_000_000_000_000;
    const E_26_U128: u128 = 100_000_000_000_000_000_000_000_000;
    const E_27_U128: u128 = 1_000_000_000_000_000_000_000_000_000;
    const E_28_U128: u128 = 10_000_000_000_000_000_000_000_000_000;
    const E_29_U128: u128 = 100_000_000_000_000_000_000_000_000_000;
    const E_30_U128: u128 = 1_000_000_000_000_000_000_000_000_000_000;
    const E_31_U128: u128 = 10_000_000_000_000_000_000_000_000_000_000;
    const E_32_U128: u128 = 100_000_000_000_000_000_000_000_000_000_000;
    const E_33_U128: u128 = 1_000_000_000_000_000_000_000_000_000_000_000;
    const E_34_U128: u128 = 10_000_000_000_000_000_000_000_000_000_000_000;
    const E_35_U128: u128 = 100_000_000_000_000_000_000_000_000_000_000_000;
    const E_36_U128: u128 = 1_000_000_000_000_000_000_000_000_000_000_000_000;
    const E_37_U128: u128 = 10_000_000_000_000_000_000_000_000_000_000_000_000;
    const E_38_U128: u128 = 100_000_000_000_000_000_000_000_000_000_000_000_000;

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

        let ratio_scaled = ((quote as u128) * DEC_MAX_U64_AS_U128) / (base as u128);
        let (log_10_ratio_scaled, last_power_of_10_scaled) = floored_log_10(ratio_scaled);

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

        // At this point, ratio_scaled could be as small as E_3_U128 = 1_000, which scales back down
        // to 1_000 * 10^-19 = 1 * 10^-16, which is the smallest value that can be represented.
        // Hence extracting the significand may require padding or truncating. If less than
        // E_7_U128, will need to pad, and if greater than E_7_U128, will need to truncate. If
        // truncating, can divide by (last_power_of_10_scaled / E_7_U128) to get the significand.
        //
        // In either case, the encoded exponent must be corrected for the shift amount.
        let (significand_encoded, exponent_encoded) =
            if (last_power_of_10_scaled < E_7_U128) { // 3 <= n < 7.
                let (pad_multiplier, exponent_shift) =
                    if (last_power_of_10_scaled < E_5_U128) { // 3 <= n < 5.
                        if (last_power_of_10_scaled < E_4_U128) { // 3 <= n < 4.
                            (E_4_U128, 4)
                        } else { // 4 <= n < 5.
                            (E_3_U128, 3)
                        }
                    } else { // 5 <= n < 7.
                        if (last_power_of_10_scaled < E_6_U128) { // 5 <= n < 6.
                            (E_2_U128, 2)
                        } else { // 6 <= n < 7.
                            (E_1_U128, 1)
                        }
                    };
                ((ratio_scaled * pad_multiplier),
                log_10_ratio_scaled + exponent_shift + EXPONENT_BIAS
                    - SIGNIFICAND_CONVERSION_SHIFT)
            } else {
                (ratio_scaled / (last_power_of_10_scaled / E_7_U128), 42)
            };
        1
    }

    #[view]
    /// Return the floored base-10 logarithm of `value` and 10 raised to that power. Uses binary
    /// search for speed, with each new branch of the tree testing at the floored midpoint of the
    /// previous branch.
    public fun floored_log_10(value: u128): (u32, u128) {
        assert!(value > 0, E_LOG_0_UNDEFINED);
        if (value < E_19_U128) { // 0 <= n < 19.
            if (value < E_9_U128) { // 0 <= n < 9.
                if (value < E_4_U128) { // 0 <= n < 4.
                    if (value < E_2_U128) { // 0 <= n < 2.
                        if (value < E_1_U128) { // 0 <= n < 1.
                            (0, E_0_U128)
                        } else {
                            (1, E_1_U128)
                        }
                    } else { // 2 <= n < 4.
                        if (value < E_3_U128) { // 2 <= n < 3.
                            (2, E_2_U128)
                        } else {
                            (3, E_3_U128)
                        }
                    }
                } else { // 4 <= n < 9.
                    if (value < E_6_U128) { // 4 <= n < 6.
                        if (value < E_5_U128) { // 4 <= n < 5.
                            (4, E_4_U128)
                        } else {
                            (5, E_5_U128)
                        }
                    } else { // 6 <= n < 9.
                        if (value < E_7_U128) { // 6 <= n < 7.
                            (6, E_6_U128)
                        } else { // 7 <= n < 9.
                            if (value < E_8_U128) { // 7 <= n < 8.
                                (7, E_7_U128)
                            } else {
                                (8, E_8_U128)
                            }
                        }
                    }
                }
            } else { // 9 <= n < 19.
                if (value < E_14_U128) { // 9 <= n < 14.
                    if (value < E_11_U128) { // 9 <= n < 11.
                        if (value < E_10_U128) { // 9 <= n < 10.
                            (9, E_9_U128)
                        } else {
                            (10, E_10_U128)
                        }
                    } else { // 11 <= n < 14.
                        if (value < E_12_U128) { // 11 <= n < 12.
                            (11, E_11_U128)
                        } else {
                            if (value < E_13_U128) { // 12 <= n < 13.
                                (12, E_12_U128)
                            } else {
                                (13, E_13_U128)
                            }
                        }
                    }
                } else { // 14 <= n < 19.
                    if (value < E_16_U128) { // 14 <= n < 16.
                        if (value < E_15_U128) { // 14 <= n < 15.
                            (14, E_14_U128)
                        } else {
                            (15, E_15_U128)
                        }
                    } else { // 16 <= n < 19.
                        if (value < E_17_U128) { // 16 <= n < 17.
                            (16, E_16_U128)
                        } else { // 17 <= n < 19.
                            if (value < E_18_U128) { // 17 <= n < 18.
                                (17, E_17_U128)
                            } else {
                                (18, E_18_U128)
                            }
                        }
                    }
                }
            }
        } else { // 19 <= n < 39.
            if (value < E_29_U128) { // 19 <= n < 29.
                if (value < E_24_U128) { // 19 <= n < 24.
                    if (value < E_21_U128) { // 19 <= n < 21.
                        if (value < E_20_U128) { // 19 <= n < 20.
                            (19, E_19_U128)
                        } else {
                            (20, E_20_U128)
                        }
                    } else { // 21 <= n < 24.
                        if (value < E_22_U128) { // 21 <= n < 22.
                            (21, E_21_U128)
                        } else { // 22 <= n < 24.
                            if (value < E_23_U128) { // 22 <= n < 23.
                                (22, E_22_U128)
                            } else {
                                (23, E_23_U128)
                            }
                        }
                    }
                } else { // 24 <= n < 29.
                    if (value < E_26_U128) { // 24 <= n < 26.
                        if (value < E_25_U128) { // 24 <= n < 25.
                            (24, E_24_U128)
                        } else {
                            (25, E_25_U128)
                        }
                    } else { // 26 <= n < 29.
                        if (value < E_27_U128) { // 26 <= n < 27.
                            (26, E_26_U128)
                        } else { // 27 <= n < 29.
                            if (value < E_28_U128) { // 27 <= n < 28.
                                (27, E_27_U128)
                            } else {
                                (28, E_28_U128)
                            }
                        }
                    }
                }
            } else { // 29 <= n < 39.
                if (value < E_34_U128) { // 29 <= n < 34.
                    if (value < E_31_U128) { // 29 <= n < 31.
                        if (value < E_30_U128) { // 29 <= n < 30.
                            (29, E_29_U128)
                        } else {
                            (30, E_30_U128)
                        }
                    } else { // 31 <= n < 34.
                        if (value < E_32_U128) { // 31 <= n < 32.
                            (31, E_31_U128)
                        } else { // 32 <= n < 34.
                            if (value < E_33_U128) { // 32 <= n < 33.
                                (32, E_32_U128)
                            } else {
                                (33, E_33_U128)
                            }
                        }
                    }
                } else { // 34 <= n < 39.
                    if (value < E_36_U128) { // 34 <= n < 36.
                        if (value < E_35_U128) { // 34 <= n < 35.
                            (34, E_34_U128)
                        } else {
                            (35, E_35_U128)
                        }
                    } else { // 36 <= n < 39.
                        if (value < E_37_U128) { // 36 <= n < 37.
                            (36, E_36_U128)
                        } else { // 37 <= n < 39.
                            if (value < E_38_U128) { // 37 <= n < 38.
                                (37, E_37_U128)
                            } else {
                                (38, E_38_U128)
                            }
                        }
                    }
                }
            }
        }
    }

    #[test_only]
    fun assert_floored_log_10(
        value: u128, expected_log: u32, expected_power: u128
    ) {
        let (log, power) = floored_log_10(value);
        assert!(log == expected_log, 1);
        assert!(power == expected_power, 2);
    }

    #[test]
    fun test_floored_log_10() {
        // Test all powers of 10.
        assert_floored_log_10(E_0_U128, 0, E_0_U128);
        assert_floored_log_10(E_1_U128, 1, E_1_U128);
        assert_floored_log_10(E_2_U128, 2, E_2_U128);
        assert_floored_log_10(E_3_U128, 3, E_3_U128);
        assert_floored_log_10(E_4_U128, 4, E_4_U128);
        assert_floored_log_10(E_5_U128, 5, E_5_U128);
        assert_floored_log_10(E_6_U128, 6, E_6_U128);
        assert_floored_log_10(E_7_U128, 7, E_7_U128);
        assert_floored_log_10(E_8_U128, 8, E_8_U128);
        assert_floored_log_10(E_9_U128, 9, E_9_U128);
        assert_floored_log_10(E_10_U128, 10, E_10_U128);
        assert_floored_log_10(E_11_U128, 11, E_11_U128);
        assert_floored_log_10(E_12_U128, 12, E_12_U128);
        assert_floored_log_10(E_13_U128, 13, E_13_U128);
        assert_floored_log_10(E_14_U128, 14, E_14_U128);
        assert_floored_log_10(E_15_U128, 15, E_15_U128);
        assert_floored_log_10(E_16_U128, 16, E_16_U128);
        assert_floored_log_10(E_17_U128, 17, E_17_U128);
        assert_floored_log_10(E_18_U128, 18, E_18_U128);
        assert_floored_log_10(E_19_U128, 19, E_19_U128);
        assert_floored_log_10(E_20_U128, 20, E_20_U128);
        assert_floored_log_10(E_21_U128, 21, E_21_U128);
        assert_floored_log_10(E_22_U128, 22, E_22_U128);
        assert_floored_log_10(E_23_U128, 23, E_23_U128);
        assert_floored_log_10(E_24_U128, 24, E_24_U128);
        assert_floored_log_10(E_25_U128, 25, E_25_U128);
        assert_floored_log_10(E_26_U128, 26, E_26_U128);
        assert_floored_log_10(E_27_U128, 27, E_27_U128);
        assert_floored_log_10(E_28_U128, 28, E_28_U128);
        assert_floored_log_10(E_29_U128, 29, E_29_U128);
        assert_floored_log_10(E_30_U128, 30, E_30_U128);
        assert_floored_log_10(E_31_U128, 31, E_31_U128);
        assert_floored_log_10(E_32_U128, 32, E_32_U128);
        assert_floored_log_10(E_33_U128, 33, E_33_U128);
        assert_floored_log_10(E_34_U128, 34, E_34_U128);
        assert_floored_log_10(E_35_U128, 35, E_35_U128);
        assert_floored_log_10(E_36_U128, 36, E_36_U128);
        assert_floored_log_10(E_37_U128, 37, E_37_U128);
        assert_floored_log_10(E_38_U128, 38, E_38_U128);

        // Test one more than each power of 10.
        assert_floored_log_10(E_0_U128 + 1, 0, E_0_U128);
        assert_floored_log_10(E_1_U128 + 1, 1, E_1_U128);
        assert_floored_log_10(E_2_U128 + 1, 2, E_2_U128);
        assert_floored_log_10(E_3_U128 + 1, 3, E_3_U128);
        assert_floored_log_10(E_4_U128 + 1, 4, E_4_U128);
        assert_floored_log_10(E_5_U128 + 1, 5, E_5_U128);
        assert_floored_log_10(E_6_U128 + 1, 6, E_6_U128);
        assert_floored_log_10(E_7_U128 + 1, 7, E_7_U128);
        assert_floored_log_10(E_8_U128 + 1, 8, E_8_U128);
        assert_floored_log_10(E_9_U128 + 1, 9, E_9_U128);
        assert_floored_log_10(E_10_U128 + 1, 10, E_10_U128);
        assert_floored_log_10(E_11_U128 + 1, 11, E_11_U128);
        assert_floored_log_10(E_12_U128 + 1, 12, E_12_U128);
        assert_floored_log_10(E_13_U128 + 1, 13, E_13_U128);
        assert_floored_log_10(E_14_U128 + 1, 14, E_14_U128);
        assert_floored_log_10(E_15_U128 + 1, 15, E_15_U128);
        assert_floored_log_10(E_16_U128 + 1, 16, E_16_U128);
        assert_floored_log_10(E_17_U128 + 1, 17, E_17_U128);
        assert_floored_log_10(E_18_U128 + 1, 18, E_18_U128);
        assert_floored_log_10(E_19_U128 + 1, 19, E_19_U128);
        assert_floored_log_10(E_20_U128 + 1, 20, E_20_U128);
        assert_floored_log_10(E_21_U128 + 1, 21, E_21_U128);
        assert_floored_log_10(E_22_U128 + 1, 22, E_22_U128);
        assert_floored_log_10(E_23_U128 + 1, 23, E_23_U128);
        assert_floored_log_10(E_24_U128 + 1, 24, E_24_U128);
        assert_floored_log_10(E_25_U128 + 1, 25, E_25_U128);
        assert_floored_log_10(E_26_U128 + 1, 26, E_26_U128);
        assert_floored_log_10(E_27_U128 + 1, 27, E_27_U128);
        assert_floored_log_10(E_28_U128 + 1, 28, E_28_U128);
        assert_floored_log_10(E_29_U128 + 1, 29, E_29_U128);
        assert_floored_log_10(E_30_U128 + 1, 30, E_30_U128);
        assert_floored_log_10(E_31_U128 + 1, 31, E_31_U128);
        assert_floored_log_10(E_32_U128 + 1, 32, E_32_U128);
        assert_floored_log_10(E_33_U128 + 1, 33, E_33_U128);
        assert_floored_log_10(E_34_U128 + 1, 34, E_34_U128);
        assert_floored_log_10(E_35_U128 + 1, 35, E_35_U128);
        assert_floored_log_10(E_36_U128 + 1, 36, E_36_U128);
        assert_floored_log_10(E_37_U128 + 1, 37, E_37_U128);
        assert_floored_log_10(E_38_U128 + 1, 38, E_38_U128);

        // Test one less than each power of 10.
        assert_floored_log_10(E_1_U128 - 1, 0, E_0_U128);
        assert_floored_log_10(E_2_U128 - 1, 1, E_1_U128);
        assert_floored_log_10(E_3_U128 - 1, 2, E_2_U128);
        assert_floored_log_10(E_4_U128 - 1, 3, E_3_U128);
        assert_floored_log_10(E_5_U128 - 1, 4, E_4_U128);
        assert_floored_log_10(E_6_U128 - 1, 5, E_5_U128);
        assert_floored_log_10(E_7_U128 - 1, 6, E_6_U128);
        assert_floored_log_10(E_8_U128 - 1, 7, E_7_U128);
        assert_floored_log_10(E_9_U128 - 1, 8, E_8_U128);
        assert_floored_log_10(E_10_U128 - 1, 9, E_9_U128);
        assert_floored_log_10(E_11_U128 - 1, 10, E_10_U128);
        assert_floored_log_10(E_12_U128 - 1, 11, E_11_U128);
        assert_floored_log_10(E_13_U128 - 1, 12, E_12_U128);
        assert_floored_log_10(E_14_U128 - 1, 13, E_13_U128);
        assert_floored_log_10(E_15_U128 - 1, 14, E_14_U128);
        assert_floored_log_10(E_16_U128 - 1, 15, E_15_U128);
        assert_floored_log_10(E_17_U128 - 1, 16, E_16_U128);
        assert_floored_log_10(E_18_U128 - 1, 17, E_17_U128);
        assert_floored_log_10(E_19_U128 - 1, 18, E_18_U128);
        assert_floored_log_10(E_20_U128 - 1, 19, E_19_U128);
        assert_floored_log_10(E_21_U128 - 1, 20, E_20_U128);
        assert_floored_log_10(E_22_U128 - 1, 21, E_21_U128);
        assert_floored_log_10(E_23_U128 - 1, 22, E_22_U128);
        assert_floored_log_10(E_24_U128 - 1, 23, E_23_U128);
        assert_floored_log_10(E_25_U128 - 1, 24, E_24_U128);
        assert_floored_log_10(E_26_U128 - 1, 25, E_25_U128);
        assert_floored_log_10(E_27_U128 - 1, 26, E_26_U128);
        assert_floored_log_10(E_28_U128 - 1, 27, E_27_U128);
        assert_floored_log_10(E_29_U128 - 1, 28, E_28_U128);
        assert_floored_log_10(E_30_U128 - 1, 29, E_29_U128);
        assert_floored_log_10(E_31_U128 - 1, 30, E_30_U128);
        assert_floored_log_10(E_32_U128 - 1, 31, E_31_U128);
        assert_floored_log_10(E_33_U128 - 1, 32, E_32_U128);
        assert_floored_log_10(E_34_U128 - 1, 33, E_33_U128);
        assert_floored_log_10(E_35_U128 - 1, 34, E_34_U128);
        assert_floored_log_10(E_36_U128 - 1, 35, E_35_U128);
        assert_floored_log_10(E_37_U128 - 1, 36, E_36_U128);
        assert_floored_log_10(E_38_U128 - 1, 37, E_37_U128);

        // Test max value that can fit in a u128.
        assert_floored_log_10(U128_MAX, 38, E_38_U128);
    }
}
