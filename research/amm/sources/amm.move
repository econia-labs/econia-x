module amm::amm {

    use fee::fee;

    #[test_only]
    use aptos_std::debug;
    #[test_only]
    use aptos_std::string_utils;
    #[test_only]
    use price::price;
    #[test_only]
    use std::string;

    public fun q_f(q_i: u64, q_in: u64): u64 {
        q_i + q_in
    }

    public fun b_v(b_i: u64, q_i: u64, q_in: u64): u64 {
        (((b_i as u128) * (q_in as u128)) / ((q_i as u128) + (q_in as u128)) as u64)
    }

    public fun b_out(b_i: u64, f: u16, q_i: u64, q_in: u64): u64 {
        (fee::remainder(f, (b_v(b_i, q_i, q_in) as u128)) as u64)
    }

    public fun b_f(b_i: u64, f: u16, q_i: u64, q_in: u64): u64 {
        b_i - b_out(b_i, f, q_i, q_in)
    }

    public fun p_t(b_i: u64, q_i: u64, f: u16, q_in: u64): u32 {
        price::price(b_out(b_i, f, q_i, q_in), q_in)
    }

    public fun p_m(b_i: u64, f: u16, q_i: u64): u32 {
        let denominator = (fee::remainder(f, (b_i as u128)) as u64);
        price::price(denominator, q_i)
    }

    public fun p_s(b_i: u64, f: u16, q_i: u64, q_in: u64): u32 {
        let numerator = q_f(q_i, q_in);
        let b_f = b_f(b_i, f, q_i, q_in);
        let denominator = (fee::remainder(f, b_f as u128) as u64);
        price::price(denominator, numerator)
    }

    public fun Q(b_i: u64, f: u16, p_s: u32): u128 {
        let (p_s_denominator, p_s_numerator) = price::ratio_irreducible(p_s);
        fee::remainder(f, (b_i as u128) * p_s_numerator / p_s_denominator)
    }

    public fun q_s(b_i: u64, f: u16, p_ask: u32, q_i: u64, q_max: u64): u64 {
        let term_Q = Q(b_i, f, p_ask);
        let numerator = (q_max as u128) * term_Q;
        let denominator = 2 * (q_max as u128) + 2 * (q_i as u128)
            - fee::fee_u128(f, term_Q);
        (numerator / denominator) as u64
    }

    #[test]
    public fun swap_buy_with_fee() {
        let b_i = 200_000_000; // Initial base reserves.
        let q_i = 100_000; // Initial quote reserves.
        let f = 10_000; // 1% fee.
        let p_m = p_m(b_i, f, q_i); // Marginal taker execution price.

        print_labeled_value(b"p_m significand", price::encoded_significand(p_m));
        print_labeled_value(b"p_m exponent", price::encoded_exponent(p_m));

        let p_ask = price::price(b_i, q_i * 11 / 10); // Ask price.

        print_labeled_value(b"p_ask significand", price::encoded_significand(p_ask));
        print_labeled_value(b"p_ask exponent", price::encoded_exponent(p_ask));

        let q_max = 20_000; // Max quote to swap in.
        let p_s_max = p_s(b_i, f, q_i, q_max); // Slippage price for max quote in.
        print_labeled_value(b"p_s_max significand", price::encoded_significand(p_s_max));
        print_labeled_value(b"p_s_max exponent", price::encoded_exponent(p_s_max));

        let q_s = q_s(b_i, f, p_ask, q_i, q_max); // Slippage quote input amount.
        print_labeled_value(b"q_s after step 1", q_s);
        q_s = q_s(b_i, f, p_ask, q_i, q_s);
        print_labeled_value(b"q_s after step 2", q_s);
        q_s = q_s(b_i, f, p_ask, q_i, q_s);
        print_labeled_value(b"q_s after step 3", q_s);
        q_s = q_s(b_i, f, p_ask, q_i, q_s);
        print_labeled_value(b"q_s after step 4", q_s);
        q_s = q_s(b_i, f, p_ask, q_i, q_s);
        print_labeled_value(b"q_s after step 5", q_s);

        let p_s = p_s(b_i, f, q_i, q_s); // Slippage price after swap.
        print_labeled_value(b"p_s significand", price::encoded_significand(p_s));
        print_labeled_value(b"p_s exponent", price::encoded_exponent(p_s));
    }

    #[test_only]
    public fun print_labeled_value<T: drop>(label: vector<u8>, value: T) {
        let msg = string::utf8(label);
        string::append(&mut msg, string::utf8(b": "));
        string::append(&mut msg, string_utils::debug_string(&value));
        debug::print(&msg);
    }
}
