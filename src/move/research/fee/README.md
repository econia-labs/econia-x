# Fees

## Base and quote

Fees can be assessed as a proportion of either base volume or quote volume
depending on the fee collector's preferred asset. As such there are two
equations for determining the fee assessed on any given trade, based on whether
the source asset (base or quote) is the input asset ("a priori fee") or output
asset ("a posteriori fee").

## Notation and units

This implementation measures fee rates in $\frac{1}{100}$ of a basis point. For
example a $1\%$ nominal fee percentage $f_{\%} = 1\%$ corresponds to an integer
fee rate of $f_i = 10,000$. Notably, fee rates can thus be encoded as a `u16`
with a maximum rate of $\frac{2^{16} - 1}{10,000} = 6.5535\%$, with the
conversion from nominal fee rate percentage to integer fee rate as follows:

$$
\begin{aligned}
f_{\%} &= \frac{f_i}{10,000} \\
f_i &= 10,000 f_{\%}
\end{aligned}
$$

Thus to assess a fee $f$ on some volume $V$:

$$
f = \frac{f_{\%}}{100} V = \frac{f_i}{1,000,000} V
$$

Note the following definition of volume:

> Volume is defined as the change in asset holdings experienced by the liquidity
> provider (maker) of a trade, independent of fees paid by the swapper (taker).
> This assumes makers do not pay a fee on provided liquidity.

For example if a taker's quote input amount is 105 quote subunits, 5 of which
are charged as fees and 100 of which are credited to the maker, the quote volume
is 100. Since fees are set aside *before* matching, this is an a priori fee.

Conversely, if filling against a maker yields 100 base subunits, 5 of which are
charged as fees and 95 of which are credited to the taker, base volume is 100.
Since fees are assessed *after* matching, this is an a posteriori fee.

## Input and output assets

The input and output asset for a taker order (simple swap) is as follows:

| Side | Input asset | Output asset |
| ---- | ----------- | ------------ |
| Buy  | Quote       | Base         |
| Sell | Base        | Quote        |

### A posteriori fees

The output asset is the fee source for the two following scenarios:

1. A swap sell with fees assessed in the quote asset.
1. A swap buy with fees assessed in the base asset.

That is, all of the input asset is credited to the maker, then a portion of the
asset yielded by the maker (volume) is taken as a fee. Consider volume $V$
yielded by the maker, comprised of $P$ proceeds to the taker and fee $f$:

$$
\begin{aligned}
P + f &= V \\
P + \frac{f_i}{1,000,000} V &= V \\
P &= V - \frac{f_i}{1,000,000} V \\
P &= V \left( 1 - \frac{f_i}{1,000,000} \right) \\
P &= V \left( \frac{1,000,000}{1,000,000} - \frac{f_i}{1,000,000} \right) \\
P&= V \left( \frac{1,000,000 - f_i}{1,000,000} \right)
\end{aligned}
$$

#### Example

Consider a swap sell with $f_{\%} = 0.5\%$ fees assessed in the quote asset,
where the maker yields $V = 40,000$ quote subunits after filling against the
base input from the swapper. The integer fee rate $f_i$:

$$
\begin{aligned}
f_i &= 10,000 f_{\%} \\
f_i &= 10,000 \cdot 0.5 \\
f_i &= 5,000
\end{aligned}
$$

The actual fee $f$:

$$
\begin{aligned}
f &= \frac{f_i}{1,000,000} V \\
f &= \frac{5,000}{1,000,000} 40,000 \\
f &= 200
\end{aligned}
$$

The proceeds $P$ to the taker:

$$
\begin{aligned}
P&= V \left( \frac{1,000,000 - f_i}{1,000,000} \right) \\
P&= 40,000 \left( \frac{1,000,000 - 5,000}{1,000,000} \right) \\
P&= 39,800
\end{aligned}
$$

The same solution holds for a swap buy with fees assessed in the base asset.

### A priori fees

The input asset is the fee source for the two following scenarios:

1. A swap buy with fees assessed in the quote asset.
1. A swap sell with fees assessed in the base asset.

That is, a portion of the input asset must be set aside to cover fees, then the
remainder (volume) can be used to fill against a maker position. Consider input
amount $I$ of source asset, comprised of volume $V$ and fee $f$:

$$
\begin{aligned}
V + f &= I \\
V + \frac{f_i}{1,000,000} V &= I \\
V \left( 1 + \frac{f_i}{1,000,000} \right) &= I \\
V \left( \frac{1,000,000}{1,000,000} + \frac{f_i}{1,000,000} \right) &= I \\
V \left( \frac{1,000,000 + f_i}{1,000,000} \right) &= I \\
V &= \left( \frac{1,000,000}{1,000,000 + f_i} \right) I
\end{aligned}
$$

Thus, solving for $f$:

$$
\begin{aligned}
f &= \frac{f_i}{1,000,000} V  \\
f &= \frac{f_i}{1,000,000} \left( \frac{1,000,000}{1,000,000 + f_i} \right) I \\
f &= \frac{f_i I }{1,000,000 + f_i}
\end{aligned}
$$

#### Example

Consider a swap buy with $f_{\%} = 1.5\%$ fees assessed in the quote asset,
where the swapper has $I = 20,300$ subunits available as an input.
The integer fee rate $f_i$:

$$
\begin{aligned}
f_i &= 10,000 f_{\%} \\
f_i &= 10,000 \cdot 1.5 \\
f_i &= 15,000
\end{aligned}
$$

The volume $V$ credited to the maker:

$$
\begin{aligned}
V &= \left( \frac{1,000,000}{1,000,000 + f_i} \right) I \\
V &= \left( \frac{1,000,000}{1,000,000 + 15,000} \right) 20,300 \\
V &= 20,000
\end{aligned}
$$

The fee $f$ paid by the taker:

$$
\begin{aligned}
f &= \frac{f_i I }{1,000,000 + f_i} \\
f &= \frac{15,000 \cdot 20,300 }{1,000,000 + 15,000} \\
f &= 300
\end{aligned}
$$

The same solution holds for a swap sell with fees assessed in the base asset.
