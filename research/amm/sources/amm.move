module amm::amm {

    #[test_only]
    use aptos_std::debug;
    #[test_only]
    use aptos_std::string_utils;
    #[test_only]
    use fee::fee;
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

    #[test]
    public fun swap_buy_with_fee() {
        let b_i = 200_000_000; // Initial base reserves.
        let q_i = 100_000; // Initial quote reserves.
        let f = 10_000; // 1% fee.
        let k_before = q_i * b_i; // Constant product before swap.
        let q_in = 100; // Quote input.

        let b_v = (b_i * q_in) / (q_i + q_in); // Base volume.
        let q_f = q_i + q_in; // Quote reserves after swap.
        print_labeled_value(b"b_v", b_v);
        // Constant product after swap, before fee reinvestment.
        let k_after = (q_f) * (b_i - b_v);
        // Compare constant product values before and after swap.
        print_labeled_value(b"k_before", k_before);
        print_labeled_value(b"k_after", k_after);

        let (_, b_out) = fee::post_match(b_v, f);
        let b_f = b_i - b_out; // Base reserves after swap.

        // Get p_m after the swap, using the final reserves.
        let (_, denominator) = fee::post_match(b_f, f);
        let p_m_after = price::price(denominator, q_f);

        // Get p_s using the initial reserves.
        let numerator = (q_i + q_in) * (q_i + q_in);
        let (inner_term, _) = fee::post_match(q_in, f);
        let (_, denominator) = fee::post_match(b_i * (q_i + inner_term), f);
        let p_s = price::price(denominator, numerator);

        // Compare price value significand values.
        print_labeled_value(
            b"p_m_after significand", price::encoded_significand(p_m_after)
        );
        print_labeled_value(b"p_s significand", price::encoded_significand(p_s));

    }

    #[test_only]
    public fun print_labeled_value<T: drop>(label: vector<u8>, value: T) {
        let msg = string::utf8(label);
        string::append(&mut msg, string::utf8(b": "));
        string::append(&mut msg, string_utils::debug_string(&value));
        debug::print(&msg);
    }
}
