# Uniswap v3 Book Milestone 1

This content is based on [milestone 1 from the Uniswap v3 book].

## Numerical algorithms

The square root algorithm (`math::sqrt`) is adapted from a [Wikipedia] example,
which notes that the search converges faster when the initial estimate is
adjusted for the binary logarithm of the operand.

Both a [stack overflow answer] and `math128` from the Aptos Standard Library
specify that the binary logarithm of an integer is equivalent to the position of
the most significant bit. Hence the binary logarithm function
(`math::log2_unchecked`) uses a simple binary search to identify the most
significant bit.

## Fixed point

For ease of representation in a `u128`, fixed point values are represented as a
`Q64.64`. This mirrors `math_fixed64` from the Aptos Standard Library. The fixed
point square root algorithm is adapted from a
[Santa Clara University programming lab supplement] as follows:

Let $x$ represent a square root operand, and $Q_x$ its `Q64.64` encoding:

```math
Q_x = 2^{64} x \tag{1}
```

Let $r$ represent the square root of $x$:

```math
r = \sqrt{x} \tag{2}
```

Encode $r$ similarly:

```math
Q_r = 2^{64} r \tag{3}
```

Define $x$ and $r$ in terms of $Q_x$ and $Q_r$:

```math
r = \frac{Q_r}{2^{64}} \tag{4}
```

```math
x = \frac{Q_x}{2^{64}} \tag{5}
```

Substituting $(4)$ and $(5)$ into $(2)$ yields:

```math
\frac{Q_r}{2^{64}} = \sqrt{\frac{Q_x}{2^{64}}}
```

```math
{Q_r} = 2^{64} \sqrt{\frac{Q_x}{2^{64}}}
```

```math
{Q_r} = \sqrt{(2^{64})^2 \frac{Q_x}{2^{64}}}
```

```math
{Q_r} = \sqrt{2^{64} Q_x} \tag{6}
```

Similarly, the multiplication operation $p = ab$ is governed by:

```math
p = ab
```

```math
\frac{Q_p}{2^{64}} = \frac{Q_a}{2^{64}} \frac{Q_b}{2^{64}}
```

```math
Q_p = \frac{Q_a Q_b}{2^{64}} \tag{7}
```

Likewise, for the division operation $q = a/b$:

```math
q = \frac{a}{b}
```

```math
\frac{Q_q}{2^{64}} = \frac{\frac{Q_a}{2^{64}}}{\frac{Q_b}{2^{64}}} =
\frac{Q_a}{Q_b}
```

```math
Q_q = \frac{2^{64} Q_a}{Q_b} \tag{8}
```

For the addition operation $s = a + b$:

```math
s = a + b
```

```math
\frac{Q_s}{2^{64}} = \frac{Q_a}{2^{64}} + \frac{Q_b}{2^{64}}
```

```math
Q_s = Q_a + Q_b \tag{9}
```

And finally, for the subtraction operation $d = a - b$:

```math
d = a - b
```

```math
\frac{Q_d}{2^{64}} = \frac{Q_a}{2^{64}} - \frac{Q_b}{2^{64}}
```

```math
Q_d = Q_a - Q_b \tag{10}
```

| Equation   | Function                       |
| ---------- | ------------------------------ |
| $(1), (3)$ | `math::u64_to_q64`             |
| $(4), (5)$ | `math::q64_to_u64`             |
| $(6)$      | `math::sqrt_q64`               |
| $(7)$      | `math::multiply_q64_unchecked` |
| $(8)$      | `math::divide_q64_unchecked`   |
| $(9)$      | `math::add_q64_unchecked`      |
| $(10)$     | `math::subtract_q64_unchecked` |

## Examples

`examples.move` contains two example tests, each with diagnostic prints:

| Test                    | Section                       |
| ----------------------- | ----------------------------- |
| `calculating_liquidity` | [Uniswap v3 book section 1.7] |
| `first_swap`            | [Uniswap v3 book section 1.9] |

To see the outputs for a single example, run something like following:

```sh
aptos move test --filter calculating_liquidity
```

### `calculating_liquidity`

For simplicity the original section does not properly account for USDC decimals,
and instead uses $10^{18}$ for both ETH and USDC subunits. Hence, for target
deposit amounts the example uses 1,000,000 base subunits and 5,000,000,000 for
quote subunits to ensure adequate precision.

### `first_swap`

Similarly, this example uses 42,000,000 quote subunits for precision, compared
with 42 in the example.

Additionally, the change in base is calculated as the absolute value of the
given expression, premultiplied by liquidity to save precision:

```math
\Delta_{base} = \frac{L}{\sqrt{P_{current}}} - \frac{L}{\sqrt{P_{target}}}
```

[milestone 1 from the uniswap v3 book]: https://uniswapv3book.com/milestone_1/introduction.html
[santa clara university programming lab supplement]: https://www.cse.scu.edu/~dlewis/book3/labs/Lab11E.pdf
[stack overflow answer]: https://stackoverflow.com/a/994709
[uniswap v3 book section 1.7]: https://uniswapv3book.com/milestone_1/calculating-liquidity.html
[uniswap v3 book section 1.9]: https://uniswapv3book.com/milestone_1/first-swap.html
[wikipedia]: https://en.wikipedia.org/wiki/Integer_square_root#Example_implementation_in_C
