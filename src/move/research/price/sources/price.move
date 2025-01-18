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

    /*
    #[view]
    /// Return the canonical price for a given ratio of base and quote.
    public fun price(base: u64, quote: u64): u32 {
        assert!(base > 0, E_BASE_ZERO);

        let ratio_scaled = ((quote as u128) * DEC_MAX_U64_AS_U128) / (base as u128);
        let exponent_scaled = floored_log_10(ratio_scaled);

        let significand = first_8_sig_figs(ratio_scaled);
        1
    }
    */

    #[view]
    /// Return the floored base-10 logarithm of `value`. Uses binary search for speed, with each new
    /// branch of the tree testing at the floored midpoint of the previous branch.
    public fun floored_log_10(value: u128): u32 {
        if (value < E_19_U128) { // 0 <= n < 19.
            if (value < E_9_U128) { // 0 <= n < 9.
                if (value < E_4_U128) { // 0 <= n < 4.
                    if (value < E_2_U128) { // 0 <= n < 2.
                        if (value < E_1_U128) { // 0 <= n < 1.
                            0
                        } else { 1 }
                    } else { // 2 <= n < 4.
                        if (value < E_3_U128) { // 2 <= n < 3.
                            2
                        } else { 3 }
                    }
                } else { // 4 <= n < 9.
                    if (value < E_6_U128) { // 4 <= n < 6.
                        if (value < E_5_U128) { // 4 <= n < 5.
                            4
                        } else { 5 }
                    } else { // 6 <= n < 9.
                        if (value < E_7_U128) { // 6 <= n < 7.
                            6
                        } else { // 7 <= n < 9.
                            if (value < E_8_U128) { // 7 <= n < 8.
                                7
                            } else { 8 }
                        }
                    }
                }
            } else { // 9 <= n < 19.
                if (value < E_14_U128) { // 9 <= n < 14.
                    if (value < E_12_U128) { // 9 <= n < 12.
                        if (value < E_10_U128) { // 9 <= n < 10.
                            9
                        } else { // 10 <= n < 12.
                            if (value < E_11_U128) { // 10 <= n < 11.
                                10
                            } else { 11 }
                        }
                    } else { // 12 <= n < 14.
                        if (value < E_13_U128) { // 12 <= n < 13.
                            12
                        } else { 13 }
                    }
                } else { // 14 <= n < 19.
                    if (value < E_16_U128) { // 14 <= n < 16.
                        if (value < E_15_U128) { // 14 <= n < 15.
                            14
                        } else { 15 }
                    } else { // 16 <= n < 19.
                       if (value < E_17_U128) { // 16 <= n < 17.
                            16
                        } else { // 17 <= n < 19.
                            if (value < E_18_U128) { // 17 <= n < 18.
                                17
                            } else { 18 }
                        }
                    }
                }
            }
        } else { // 19 <= n < 39.
            if (value < E_29_U128) { // 19 <= n < 29.
                if (value < E_24_U128) { // 19 <= n < 24.
                    if (value < E_21_U128) { // 19 <= n < 21.
                        if (value < E_20_U128) { // 19 <= n < 20.
                            19
                        } else { 20 }
                    } else { // 21 <= n < 24.
                        if (value < E_22_U128) { // 21 <= n < 22.
                            21
                        } else { // 22 <= n < 24.
                            if (value < E_23_U128) { // 22 <= n < 23.
                                22
                            } else { 23 }
                        }
                    }
                } else { // 24 <= n < 29.
                    if (value < E_26_U128) { // 24 <= n < 26.
                        if (value < E_25_U128) { // 24 <= n < 25.
                            24
                        } else { 25 }
                    } else { // 26 <= n < 29.
                        if (value < E_27_U128) { // 26 <= n < 27.
                            26
                        } else { // 27 <= n < 29.
                            if (value < E_28_U128) { // 27 <= n < 28.
                                27
                            } else { 28 }
                        }
                    }
                }
            } else { // 29 <= n < 39.
                if (value < E_34_U128) { // 29 <= n < 34.
                    if (value < E_31_U128) { // 29 <= n < 31.
                        if (value < E_30_U128) { // 29 <= n < 30.
                            29
                        } else { 30 }
                    } else { // 31 <= n < 34.
                        if (value < E_32_U128) { // 31 <= n < 32.
                            31
                        } else { // 32 <= n < 34.
                            if (value < E_33_U128) { // 32 <= n < 33.
                                32
                            } else { 33 }
                        }
                    }
                } else { // 34 <= n < 39.
                    16
                }
            }
        }
    }

    #[test]
    fun test_floored_log_10() {
        // Test all constants up through E_38_U128.
        assert!(floored_log_10(E_0_U128) == 0);
        assert!(floored_log_10(E_1_U128) == 1);
        assert!(floored_log_10(E_2_U128) == 2);
        assert!(floored_log_10(E_3_U128) == 3);
        assert!(floored_log_10(E_4_U128) == 4);
        assert!(floored_log_10(E_5_U128) == 5);
        assert!(floored_log_10(E_6_U128) == 6);
        assert!(floored_log_10(E_7_U128) == 7);
        assert!(floored_log_10(E_8_U128) == 8);
        assert!(floored_log_10(E_9_U128) == 9);
        assert!(floored_log_10(E_10_U128) == 10);
        assert!(floored_log_10(E_11_U128) == 11);
        assert!(floored_log_10(E_12_U128) == 12);
        assert!(floored_log_10(E_13_U128) == 13);
        assert!(floored_log_10(E_14_U128) == 14);
        assert!(floored_log_10(E_15_U128) == 15);
        assert!(floored_log_10(E_16_U128) == 16);
        assert!(floored_log_10(E_17_U128) == 17);
        assert!(floored_log_10(E_18_U128) == 18);
        assert!(floored_log_10(E_19_U128) == 19);
        assert!(floored_log_10(E_20_U128) == 20);
        assert!(floored_log_10(E_21_U128) == 21);
        assert!(floored_log_10(E_22_U128) == 22);
        assert!(floored_log_10(E_23_U128) == 23);
        assert!(floored_log_10(E_24_U128) == 24);
        assert!(floored_log_10(E_25_U128) == 25);
        assert!(floored_log_10(E_26_U128) == 26);
        assert!(floored_log_10(E_27_U128) == 27);
        assert!(floored_log_10(E_28_U128) == 28);
        assert!(floored_log_10(E_29_U128) == 29);
        assert!(floored_log_10(E_30_U128) == 30);
        assert!(floored_log_10(E_31_U128) == 31);
        assert!(floored_log_10(E_32_U128) == 32);
        assert!(floored_log_10(E_33_U128) == 33);
        assert!(floored_log_10(E_34_U128) == 34);
        assert!(floored_log_10(E_35_U128) == 35);
        assert!(floored_log_10(E_36_U128) == 36);
        assert!(floored_log_10(E_37_U128) == 37);
        assert!(floored_log_10(E_38_U128) == 38);

        // u128 max
        // each value + 1
        // each value - 1

    }
}
