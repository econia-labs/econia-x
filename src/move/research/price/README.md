# Price

## General

This implementation defines price $p$ as the ratio of a quote asset $q$ to a
base asset $b$:

$$
p = \frac{q}{b}
$$

Prices are denoted using an unsigned [normalized number] format, so at current
market prices as of the time of this writing, for example, the ratio of 9.79
`USD` per 1 `APT` would be denoted $p = 9.79 \cdot 10^1$:

$$
p = \frac{9.79}{1} = 9.79 \cdot 10^1
$$

The chosen `u32` format ensures a canonical encoding of any representable
number, resulting in a strict total order:

| Bits  | Encoded data | Symbol |
| ----- | ------------ | ------ |
| 0—26  | Significand  | $m$    |
| 27—31 | Exponent     | $n$    |

Hence for a normalized significand $1 \leq m < 10$, price $p$ is denoted:

$$
p = m \cdot 10^n
$$

## Significant digits

With 27 bits, the significand can theoretically encode any natural number $n$
for $0 \leq n \leq 2^{27} - 1 = 134217727$.

However in practice, a given significand $s$ is bounded between
$s_{min} = 100000000 = 10^8$ and $s_{max} = 999999999 \approx 10^9$
($s_{min} \leq s \leq s_{max}$), to ensure a canonical encoding for any given
representable number. For example the number $1.5$ is represented as
$1.5 = 150000000 \cdot 10^{-8}$.

## Bias derivation

With 5 bits, the exponent can theoretically encode any natural number $n$ for
$0 \leq n \leq 2^5 - 1 = 31$.

However in practice, due to the bounds on $s_{min}$ and $s_{max}$, negative
exponents are required to represent numbers smaller than $s_{min}$, like $1.5$.

Hence for a given significand $s$, there are thus 32 possible prices ranging
from $s \cdot 10 ^ {e_{min}}$ to $s \cdot 10 ^ {e_{max}}$ across different
orders of magnitude.

Note that any significand can be represented as
$s = a \cdot s_{min} = a \cdot 10^8$, thus converting it to normalized
scientific notation for $1 \leq a \lt 10$. Hence the range of prices for any
given significand $s$ resolves to a lower bound of $a \cdot 10 ^ {8 + e_{min}}$
and an upper bound of $a \cdot 10 ^ {8 + e_{max}}$.

Given the number of bits allowed, ensuring adequate range across both positive
and negative exponents requires solving the system of equations:

$$8 + e_{min} = -(8 + e_{max})$$

$$e_{max} - e_{min} = 31$$

The solution $e_{max} = 7.5, e_{min} = -23.5$, however, does not yield integers,
so the results are rounded to $e_{max} = 8, e_{min}=-23$, resulting in an
effective price range (scientific notation) between $a \cdot 10^{-15}$ and
$a \cdot 10^{16}$. This is consistent with the [IEE 754 standard], which defines
exponent ranges between $-126$ and $+127$, $-1022$ and $+1023$, and so on
(`emin = 1 - emax`).

[iee 754 standard]: https://en.wikipedia.org/wiki/IEEE_754
[normalized number]: https://en.wikipedia.org/wiki/Normalized_number
