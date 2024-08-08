# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Actually, just string utils."""


# ------ List[StringableCollectionElement] to String
#
fn str_[
    T: StringableCollectionElement
](
    list: List[T], *, sep: StringLiteral = "\n", beg: StringLiteral = "", end: StringLiteral = "\n"
) -> String:
    var result: String = beg
    var last: Int = len(list) - 1
    for i in range(last):
        result += str(list[i]) + sep
    if len(list) > 0:
        result += str(list[last])
    return result + end


fn print_[
    T: StringableCollectionElement
](list: List[T], *, sep: StringLiteral = "\n", beg: StringLiteral = "", end: StringLiteral = "\n"):
    print(str_(list, sep=sep, beg=beg, end=end))


@always_inline
fn repeat(string: String, amount: Int) -> String:
    var result = String()
    for i in range(amount):
        result += string
    return result


@always_inline
fn repeat[__: None = None](char: Char, amount: Int) -> String:
    var result = String()
    for i in range(amount):
        result += str(char)
    return result


@always_inline
fn padl[char: Char = " "](string: String, amount: Int = 1) -> String:
    return repeat(char, amount) + string


@always_inline
fn padr[char: Char = " "](string: String, amount: Int = 1) -> String:
    return string + repeat(char, amount)


@always_inline
fn compare(lo: String, hi: String) -> Int:
    var len_lo = len(lo)
    var len_hi = len(hi)
    for i in range(min(len_lo, len_hi)):
        if Char(lo[i]) < Char(hi[i]):
            return 1
        if Char(lo[i]) > Char(hi[i]):
            return -1
    if len_lo < len_hi:
        return 1
    if len_lo > len_hi:
        return -1
    return 0
