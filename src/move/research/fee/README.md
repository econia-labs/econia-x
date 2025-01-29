# Fees

## Base and quote

Fees can be assessed as a proportion of either size (base subunits) or volume
(quote subunits) depending on the fee collector's preferred asset. As such there
are two equations for determining the fee assessed on any given trade, based on
whether the source asset (base or quote) is the input or output asset.

## Notation and units

This implementation measures fee rates in $\frac{1}{100}$ of a basis point. For
example a $1\%$ nominal fee percentage $f_{\%} = 1\%$ corresponds to an integer
fee rate of $f_i = 10,000$. Notably, fee rates can thus be encoded as a `u16`
with a maximum rate of $\frac{2^{16} - 1}{10,000} = 6.5535\%$, with the
conversion from nominal fee rate percentage to integer fee rate as follows:

$$
f_{\%} = \frac{f_i}{10,000}\%
$$

## Input and output assets

The input and output asset for a taker order (simple swap) is as follows:

| Side | Input asset | Output asset |
| ---- | ----------- | ------------ |
| Buy  | Quote       | Base         |
| Sell | Base        | Quote        |
