# Fees

## Base and quote

Fees can be assessed as a proportion of either base volume or quote volume
depending on the fee collector's preferred asset. As such there are two
equations for determining the fee assessed on any given trade, based on whether
the source asset (base or quote) is the input or output asset.

## Notation and units

This implementation measures fee rates in $\frac{1}{100}$ of a basis point. For
example a $1\%$ nominal fee percentage $f_{\%} = 1\%$ corresponds to an integer
fee rate of $f_i = 10,000$. Notably, fee rates can thus be encoded as a `u16`
with a maximum rate of $\frac{2^{16} - 1}{10,000} = 6.5535\%$, with the
conversion from nominal fee rate percentage to integer fee rate as follows:

$$
f_{\%} = \frac{f_i}{10,000}\%
$$

Thus to assess a fee $f$ on some volume $V$:

$$
f = \frac{f_{\%}}{100} V = \frac{f_i}{1,000,000} V
$$

## Input and output assets

The input and output asset for a taker order (simple swap) is as follows:

| Side | Input asset | Output asset |
| ---- | ----------- | ------------ |
| Buy  | Quote       | Base         |
| Sell | Base        | Quote        |

### Output as source

The output asset is the fee source for the two following scenarios:

1. A swap sell with fees assessed in the quote asset.
1. A swap buy with fees denominated in the base asset.

That is, all of the input asset is used to match against the maker position,
then a portion of the proceeds (volume) is taken as a fee.

### Input as source

The input asset is the fee source for the two following scenarios:

1. A swap buy with fees assessed in the quote asset.
1. A swap sell with fees denominated in the base asset.

That is, a portion of the input asset must be set aside to cover fees, then the
remainder (volume) can be used to fill against a maker position. Consider input
amount $I$ of source asset, comprised of volume $V$ and fee $f$:

$$
\begin{aligned}
I &= V + f \\
I &= V + \frac{f_i}{1,000,000} V \\
I &= V \left( 1 + \frac{f_i}{1,000,000} \right) \\
I &= V \left( \frac{1,000,000}{1,000,000} + \frac{f_i}{1,000,000} \right) \\
I &= V \left( \frac{1,000,000 + f_i}{1,000,000} \right) \\
I \left( \frac{1,000,000}{1,000,000 + f_i} \right) &= V \\
\end{aligned}
$$

Thus, solving for $f$:

$$
\begin{aligned}
f &= \frac{f_i}{1,000,000} V  \\
f &= \frac{f_i}{1,000,000} I \left( \frac{1,000,000}{1,000,000 + f_i} \right) \\
f &= \frac{f_i I }{1,000,000 + f_i}
\end{aligned}
$$

For example, consider a swap buy with $f_{\%} = 1.5\%$ fees assessed in the
quote asset, where the user has $I = 20,003$ subunits available as an input:

$$
\begin{aligned}
V &= 20,003 \left( \frac{1,000,000}{1,000,000 + 150} \right) \\
V &= 20,000
\end{aligned}
$$

$$
\begin{aligned}
f &= \frac{150}{1,000,000} 20,000  \\
f &= 3
\end{aligned}
$$

The same solution holds for a swap sell with fees assessed in the base asset.
