trait Representable(Stringable):
    """
    The `Representable` trait describes a type that has a `String` representation.

    Enforces `__repr__()` to be implemented, and can be used with the `repr()` function.

    Parsing somethings representation should give you the same thing back.

    Ignores escape characters. (for the most part)
    """
    fn __repr__(self) -> String: ...

@always_inline
fn repr[T: Representable](value: T) -> String: return value.__repr__()

@always_inline
fn repr[T: Stringable, __:None=None](value: T) -> String:
    var string = str(value)
    var result = String()
    for i in range(len(string)):
        result += repr(Char(string[i]))
    return result

@always_inline
fn repeat(string: String, amount: Int) -> String:
    var result = String()
    for i in range(amount): result += string
    return result

@always_inline
fn repeat[__:None=None](char: Char, amount: Int) -> String:
    var result = String()
    for i in range(amount): result += char
    return result

@always_inline
fn padl[char: Char = " "](string: String, amount: Int = 1) -> String:
    return repeat(char, amount) + string

@always_inline
fn padr[char: Char = " "](string: String, amount: Int = 1) -> String:
    return string + repeat(char, amount)


from math import min

@always_inline
fn compare(lo: String, hi: String) -> Int:
    var len_lo = len(lo)
    var len_hi = len(hi)
    for i in range(min(len_lo, len_hi)):
        if Char(lo[i]) < Char(hi[i]): return 1
        if Char(lo[i]) > Char(hi[i]): return -1
    if len_lo < len_hi: return 1
    if len_lo > len_hi: return -1
    return 0