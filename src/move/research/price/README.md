<!--- cspell:word-->

# Price

## General

This implementation defines price $p$ as the ratio of a quote asset $q$ to a
base asset $b$:

$$
p = \frac{q}{b}
$$

Prices are denoted using an unsigned [normalized number] format, so at current
market prices as of the time of this writing, for example, the ratio of $9.79$
`USD` per $1$ `APT` would be denoted $p = 9.79 \cdot 10^1$:

$$
p = \frac{9.79}{1} = 9.79 \cdot 10^1
$$

The chosen `u32` format ensures a canonical encoding of any representable
number, resulting in a strict total order:

| Bits  | Encoded data | Symbol | Restriction              |
| ----- | ------------ | ------ | ------------------------ |
| 0—26  | Significand  | $m$    | Max 9 significant digits |
| 27—31 | Exponent     | $n$    | $-16 \leq n \leq 15$     |

Hence for a normalized significand $1 \leq m < 10$, price $p$ is denoted:

$$
p = m \cdot 10^n
$$

## Old

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

## Exponent range selection

With 5 `u32` bits allocated for $n$, there are thus $2^5 = 32$ possible
exponents. Since $n=0$ exhausts one representable exponent, the selection of a
symmetric range across different orders of magnitude requires choosing between
two options:

| Option | Lower bound     | Upper bound     | Range                   |
| ------ | --------------- | --------------- | ----------------------- |
| 1      | $n_{min} = -16$ | $n_{max} = +15$ | $ -16 \leq n \leq +15 $ |
| 2      | $n_{min} = -15$ | $n_{max} = +16$ | $ -15 \leq n \leq +16 $ |

To simplify the decision making process, consider an analogous 2-bit exponent
with options A and B:

| Option | Lower bound    | Upper bound    | Range                 |
| ------ | -------------- | -------------- | --------------------- |
| A      | $n_{min} = -2$ | $n_{max} = +1$ | $ -2 \leq n \leq +1 $ |
| B      | $n_{min} = -1$ | $n_{max} = +2$ | $ -1 \leq n \leq +2 $ |

Now consider the lowest possible significand $m_{min} = 1.0$ and the highest
possible significand $m_{max} = 9.99$ (for 3 significant digits). For option A:

<!-- markdownlint-disable MD013 -->

|                      | Smallest exponent                         | Largest exponent                       |
| -------------------- | ----------------------------------------- | -------------------------------------- |
| Smallest significand | $1.00 \cdot 10^{-2} = 0.01$               | $1.00 \cdot 10^{1} = 10$               |
| Largest significand  | $9.99 \cdot 10^{-2} = 0.0999 \approx 0.1$ | $9.99 \cdot 10^{1} = 99.9 \approx 100$ |

<!-- markdownlint-enable MD013 -->

And for option B:

<!-- markdownlint-disable MD013 -->

|                      | Smallest exponent                       | Largest exponent                       |
| -------------------- | --------------------------------------- | -------------------------------------- |
| Smallest significand | $1.00 \cdot 10^{-1} = 0.1$              | $1.00 \cdot 10^{2} = 100$              |
| Largest significand  | $9.99 \cdot 10^{-1} = 0.999 \approx 1 $ | $9.99 \cdot 10^{2} = 999 \approx 1000$ |

<!-- markdownlint-enable MD013 -->

Option A ($|n_{min}| = |n_{max}| + 1$) presents several advantages:

1. In option A, the smallest representable number
   $p_{min} = m_{min} \cdot 10^{n_{min}} = 0.01$ straddles the number $1$ by two
   orders of magnitude, as does the largest representable number,
   $p_{max} = m_{max} \cdot 10^{n_{max}} \approx 100$. This contrast with option
   B where $p_min = 0.1$ is 1 order less but $p_{max} \approx 1000$ is
   (approximately) 3 more.
1. In option B for the largest significand $m_{max} = 9.99$, the smallest
   representable number $m_{max} \cdot 10 ^ {n_{min}} = 0.999 \approx 1$ is
   (approximately) $1$, while the largest representable number
   $m_{max} \cdot 10 ^ {n_{max}} = 9.99 \approx 1000$ is (approximately) 3
   orders of magnitude above $1$. This asymmetric arrangement impractical, with
   effectively no dynamic range below $1$.

Hence Option A, is the more practical choice, and by extension for the given
implementation, option 1, which also has $|n_{min}| = |n_{max}| + 1$:

| Lower bound     | Upper bound     | Range                   |
| --------------- | --------------- | ----------------------- |
| $n_{min} = -16$ | $n_{max} = +15$ | $ -16 \leq n \leq +15 $ |

[iee 754 standard]: https://en.wikipedia.org/wiki/IEEE_754
[normalized number]: https://en.wikipedia.org/wiki/Normalized_number
