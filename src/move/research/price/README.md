# Econia canonical price

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
| 0—26  | Significand  | $m$    | Max 8 significant digits |
| 27—31 | Exponent     | $n$    | $-16 \leq n \leq 15$     |

Hence for a normalized significand $1 \leq m < 10$, price $p$ is denoted:

$$
p = m \cdot 10^n
$$

## Encoding

The 27 significand bits can theoretically encode any natural number $n$ for
$0 \leq n \leq 2^{27} - 1 = 134,217,727$.

However in practice the encoded value $m_e$ is bounded as follows to ensure
a canonical representation of any possible number:

$$
10^7 = 10,000,000 = m_{e, min}\leq m_e \leq m_{e, max} = 99,999,999 \approx 10^8
$$

This constraint thus disambiguates numbers that do not use all significant
digits, resulting in a strict total order among all representable prices. For
example the price $1.5 \cdot 10^1$ would have an encoded significand
$m_e = 15,000,000$, and more generally, conversion between a normalized
significand $m$ and encoded significand $m_e$ is as follows:

$$
m_e = m \cdot 10^7
$$

Similarly, conversion between a normalized exponent $n$ and encoded exponent
$n_e$ requires a bias to encode negative values:

$$
n_e = n + 16
$$

Thus, the price $987 = 9.87 \cdot 10^2$ is encoded as follows:

<!-- markdownlint-disable MD013 -->

| Description         | Symbol | Encoded value                  | Bits                          |
| ------------------- | ------ | ------------------------------ | ----------------------------- |
| Encoded significand | $m_e$  | $9.87 \cdot 10^7 = 98,700,000$ | `101111000100000101011100000` |
| Encoded exponent    | $n_e$  | $2 + 16 = 18$                  | `10010`                       |

<!-- markdownlint-enable MD013 -->

> ```txt
>               10010101111000100000101011100000
> exponent bits ^^^^^
>                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^ significand bits
> ```

## Exponent range selection

With 5 `u32` bits allocated for $n_e$, there are thus $2^5 = 32$ possible
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

Hence option A is the more practical choice, and by extension for the given
implementation, option 1, which also has $|n_{min}| = |n_{max}| + 1$:

| Lower bound     | Upper bound     | Range                   |
| --------------- | --------------- | ----------------------- |
| $n_{min} = -16$ | $n_{max} = +15$ | $ -16 \leq n \leq +15 $ |

[normalized number]: https://en.wikipedia.org/wiki/Normalized_number
