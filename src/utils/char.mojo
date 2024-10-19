# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Implements a `Char` type."""
from collections.string import _chr_ascii, _repr_ascii


# +----------------------------------------------------------------------------------------------+ #
# | Character Sets
# +----------------------------------------------------------------------------------------------+ #
#
struct CharSet:
    """Character sets as strings."""

    alias upper_case = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    alias lower_case = "abcdefghijklmnopqrstuvwxyz"
    alias numbers = "0123456789"
    alias symbols = " !\"#$&%'()*+,-./:;<=>?@[\\]^_`{|}~"
    alias control = "\0\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x7f"
    alias letters = Self.upper_case + Self.lower_case
    alias alphanumeric = Self.letters + Self.numbers
    alias printable = Self.alphanumeric + Self.symbols
    alias reduced = Self.printable + Self.control


# +----------------------------------------------------------------------------------------------+ #
# | Box Characters
# +----------------------------------------------------------------------------------------------+ #
#
struct BoxChar:
    """Box character macros as strings."""

    alias vertical = "\xe2\x94\x82"
    alias horizontal = "\xe2\x94\x80"
    alias vertical_right = "\xe2\x94\x9c"
    alias horizontal_down = "\xe2\x94\xac"
    alias upper_right = "\xe2\x94\x94"


# +----------------------------------------------------------------------------------------------+ #
# | Char
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct Char(Representable, CollectionElement, KeyElement, Intable):
    """Represents a single ASCII character."""

    var value: Scalar[DType.uint8]

    @always_inline("nodebug")
    fn __init__(inout self, none: None = None):
        self.value = 0

    @always_inline
    fn __init__(inout self, char: Scalar[DType.uint8]):
        self.value = char

    @always_inline
    fn __init__(inout self, char: StringLiteral):
        self.value = ord(char)

    @always_inline
    fn __init__[__: None = None](inout self, char: String):
        self.value = ord(char)

    @always_inline
    fn __str__(self) -> String:
        return _chr_ascii(self.value)

    @always_inline
    fn __repr__(self) -> String:
        return _repr_ascii(self.value)

    @always_inline
    fn write_to[WriterType: Writer, //](self, inout writer: WriterType):
        writer.write(self.__str__())

    @always_inline
    fn __hash__(self) -> UInt:
        return hash(self.value)

    @always_inline
    fn __lt__(self, other: Self) -> Bool:
        return self.value < other.value

    @always_inline
    fn __le__(self, other: Self) -> Bool:
        return self.value <= other.value

    @always_inline
    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    @always_inline
    fn __gt__(self, other: Self) -> Bool:
        return self.value > other.value

    @always_inline
    fn __ge__(self, other: Self) -> Bool:
        return self.value >= other.value

    @always_inline
    fn __ne__(self, other: Self) -> Bool:
        return self.value != other.value

    @always_inline
    fn __add__[__: None = None](self, other: Char) -> String:
        return str(self) + str(other)

    @always_inline
    fn __add__(self, other: String) -> String:
        return str(self) + other

    @always_inline
    fn __radd__[__: None = None](self, other: Char) -> String:
        return str(other) + str(self)

    @always_inline
    fn __radd__(self, other: String) -> String:
        return other + str(self)

    @always_inline
    fn __int__(self) -> Int:
        return int(self.value)
