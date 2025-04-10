---
layout: post
title:  "Number Representation"
date:   2025-04-04
tag: Computer Architecture
---

# Digit

If we have an n-digit unsigned numeral $d_{n-1}d_{n-2}...d_{0}$ in radix r, then we can convert it to a decimal number by

$$

\sum_{i=0}^{n-1}r^i d_i

$$

If we want to convert a decimal number to a numeral in radix r, we can let the number divided by r and note down the remainder. Then let the quotient divided by r until we get 0 as the quotient. Write the remainders in such way that the last remainder is written first. For example, we convert 13 to a binary number.

$$
13 / 2= 6...1 \\ 6/2=3...0 \\ 3/2 = 1...1 \\ 1/2 = 0...1
$$

Or we can let the number minus the number in radix r with the largest exponent smaller than it. Then we let the remainder minus. We repeat until the difference becomes 0. We add all subtracters to get the result.

$$
13 - 2^3=5 \\5-2^2=1\\ 1-2^0 =0 \\1000+0100+0001
$$

The result is 0b1101

# Negative Number

There’re two common schemes to deal with the negative number

**Two’s complement** 

- Negative numbers will have a 1 as their most significant bit (MSB).
- Positive number will have a 0 as their MSB.
- But if you just use this method, the addition would be very complex. So we flip all the bits of the number. Each number of the sum of it and its positive number is 1, such as 0001 + 1110 = 111. If you add 1, then the sum will be 0 as the highest 1 is abandoned due to the length of the type. So we add 1 to the flipped number then you get its negative form. For example, 7 = 0111, - 7 = 1001, 7-7=0.
- Addition of a positive number and a negative number is exactly the same as with an unsigned number.

**Biased**

- The smallest representable number is 0b0…0
- We subtract the origin number by a negative bias so that the representable number of a negative number will be positive .
- A common used bias for N-bits is $-(2^{N-1}-1)$. If N=8, the bias is -127.

Addition and subtraction of binary/hex numbers can be done in a similar fashion as with decimal digits by working right to left and carrying over extra digits to the next place. For example 10 - 01, you add 2 to the right most 0 and 2 - 1 = 1. The result is 01.

# Float

The IEEE 754 standard defines a binary representation for floating point values using three fields.

- The sign determines the sign of the number (0 for positive, 1 for negative).
- The exponent is in biased notation. For instance, the bias is -127  for single-precision (32-bit)  
 floating point numbers.
- The significand or mantissa is akin to unsigned integers, but used to store a fraction instead of an integer.

The below table shows the bit breakdown for the single precision (32-bit) representation. The leftmost bit is the MSB and the rightmost bit is the LSB. 

![Untitled]({{"/assets/images/Number-Representation.png"   | relative_url }})

For normalized floats:

$$
 (-1)^{\text{Sign}} ∗ 2^{\text{Exp+Bias}} ∗ 1.\text{significand}_2
$$

For denormalized floats:

$$
 (-1)^{\text{Sign}} ∗ 2^{\text{Exp+Bias}+1} ∗ 0.\text{significand}_2
$$

| Exponent | Significand | Meaning |
| --- | --- | --- |
| 0 | Anything | Denorm |
| 1-254 | Anything | Normal |
| 255 | 0 | Infinity |
| 255 | Nonzero | NaN |

