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
    for _ in range(amount):
        result += string
    return result


@no_inline
fn write_repeated[*Ts: Formattable](inout writer: Formatter, *items: *Ts, amount: Int):
    @parameter
    @always_inline
    fn _write[T: Formattable](item: T):
        item.format_to(writer)

    for _ in range(amount):
        items.each[_write]()


@no_inline
fn write_ljust[
    T: Formattable
](inout writer: Formatter, item: T, width: Int, fillchar: StringLiteral = " "):
    var item_str = String.format_sequence(item)
    writer.write(item_str)
    write_repeated(writer, fillchar, amount=width - len(item_str))


@no_inline
fn write_rjust[
    T: Formattable
](inout writer: Formatter, item: T, width: Int, fillchar: StringLiteral = " "):
    var item_str = String.format_sequence(item)
    write_repeated(writer, fillchar, amount=width - len(item_str))
    writer.write(item_str)


@always_inline
fn lpad(string: String, amount: Int = 1, fillchar: Char = " ") -> String:
    var result = String()
    var writer = result._unsafe_to_formatter()
    write_repeated(writer, fillchar, amount=amount)
    writer.write(string)
    return result


@always_inline
fn rpad(string: String, amount: Int = 1, fillchar: Char = " ") -> String:
    var result = String()
    var writer = result._unsafe_to_formatter()
    writer.write(string)
    write_repeated(writer, fillchar, amount=amount)
    return result


@always_inline
fn repeat[__: None = None](char: Char, amount: Int) -> String:
    var result = String()
    for _ in range(amount):
        result += str(char)
    return result


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
