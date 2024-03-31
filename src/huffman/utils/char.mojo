"""
Implements a char and aliases for 
"""

struct CharSet:
    """
    Character sets as strings.
    """
    alias upper_case = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    alias lower_case = "abcdefghijklmnopqrstuvwxyz"
    alias numbers = "0123456789"
    alias symbols = " !\"#$&%'()*+,-./:;<=>?@[\\]^_`{|}~"
    alias control = "\0\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x7f"
    alias letters = Self.upper_case + Self.lower_case
    alias alphanumeric = Self.letters + Self.numbers
    alias printable = Self.alphanumeric + Self.symbols
    alias reduced = Self.printable + Self.control

struct BoxChar:
    """
    Box character macros as strings.
    """
    alias vertical = "\xe2\x94\x82"
    alias horizontal = "\xe2\x94\x80"
    alias vertical_right = "\xe2\x94\x9c"
    alias horizontal_down = "\xe2\x94\xac"
    alias upper_right = "\xe2\x94\x94"

@register_passable("trivial")
struct Char(Representable, CollectionElement, KeyElement):
    """
    Represents a single ASCII character.
    """

    var value: Scalar[DType.int8]

    @always_inline
    fn __init__(null: None) -> Self:
        return Self{value:0}

    @always_inline
    fn __init__(char: Scalar[DType.int8]) -> Self:
        return Self{value:char}

    @always_inline
    fn __init__(char: StringLiteral) -> Self:
        return Self{value:ord(char)}

    @always_inline
    fn __init__[__:None=None](char: String) -> Self:
        return Self{value:ord(char)}

    @always_inline
    fn __str__(self) -> String:
        return chr(self.value.to_int())

    @always_inline
    fn __repr__(self) -> String:
        alias _table = StaticTuple[StringLiteral, 256](
            "\\0",   "\\x01", "\\x02", "\\x03", "\\x04", "\\x05", "\\x06", "\\a",   "\\b",   "\\t",   "\\n",   "\\v",   "\\f",   "\\r",   "\\x0e", "\\x0f",
            "\\x10", "\\x11", "\\x12", "\\x13", "\\x14", "\\x15", "\\x16", "\\x17", "\\x18", "\\x19", "\\x1a", "\\x1b", "\\x1c", "\\x1d", "\\x1e", "\\x1f",
            " ",     "!",     "\"",    "#",     "$",     "&",     "%",     "'",     "(",     ")",     "*",     "+",     ",",     "-",     ".",     "/",
            "0",     "1",     "2",     "3",     "4",     "5",     "6",     "7",     "8",     "9",     ":",     ";",     "<",     "=",     ">",     "?",
            "@",     "A",     "B",     "C",     "D",     "E",     "F",     "G",     "H",     "I",     "J",     "K",     "L",     "M",     "N",     "O",
            "P",     "Q",     "R",     "S",     "T",     "U",     "V",     "W",     "X",     "Y",     "Z",     "[",     "\\",    "]",     "^",     "_",
            "`",     "a",     "b",     "c",     "d",     "e",     "f",     "g",     "h",     "i",     "j",     "k",     "l",     "m",     "n",     "o",
            "p",     "q",     "r",     "s",     "t",     "u",     "v",     "w",     "x",     "y",     "z",     "{",     "|",     "}",     "~",     "\\x7f",
            "\\x80", "\\x81", "\\x82", "\\x83", "\\x84", "\\x85", "\\x86", "\\x87", "\\x88", "\\x89", "\\x8a", "\\x8b", "\\x8c", "\\x8d", "\\x8e", "\\x8f",
            "\\x90", "\\x91", "\\x92", "\\x93", "\\x94", "\\x95", "\\x96", "\\x97", "\\x98", "\\x99", "\\x9a", "\\x9b", "\\x9c", "\\x9d", "\\x9e", "\\x9f",
            "\\xa0", "\\xa1", "\\xa2", "\\xa3", "\\xa4", "\\xa5", "\\xa6", "\\xa7", "\\xa8", "\\xa9", "\\xaa", "\\xab", "\\xac", "\\xad", "\\xae", "\\xaf",
            "\\xb0", "\\xb1", "\\xb2", "\\xb3", "\\xb4", "\\xb5", "\\xb6", "\\xb7", "\\xb8", "\\xb9", "\\xba", "\\xbb", "\\xbc", "\\xbd", "\\xbe", "\\xbf",
            "\\xc0", "\\xc1", "\\xc2", "\\xc3", "\\xc4", "\\xc5", "\\xc6", "\\xc7", "\\xc8", "\\xc9", "\\xca", "\\xcb", "\\xcc", "\\xcd", "\\xce", "\\xcf",
            "\\xd0", "\\xd1", "\\xd2", "\\xd3", "\\xd4", "\\xd5", "\\xd6", "\\xd7", "\\xd8", "\\xd9", "\\xda", "\\xdb", "\\xdc", "\\xdd", "\\xde", "\\xdf",
            "\\xe0", "\\xe1", "\\xe2", "\\xe3", "\\xe4", "\\xe5", "\\xe6", "\\xe7", "\\xe8", "\\xe9", "\\xea", "\\xeb", "\\xec", "\\xed", "\\xee", "\\xef",
            "\\xf0", "\\xf1", "\\xf2", "\\xf3", "\\xf4", "\\xf5", "\\xf6", "\\xf7", "\\xf8", "\\xf9", "\\xfa", "\\xfb", "\\xfc", "\\xfd", "\\xfe", "\\xff",
            )
        return _table[self.to_int() % 256]

    @always_inline
    fn __hash__(self) -> Int:
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
    fn __add__[__:None=None](self, other: Char) -> String:
        return str(self) + str(other)

    @always_inline
    fn __add__(self, other: String) -> String:
        return str(self) + other

    @always_inline
    fn __radd__[__:None=None](self, other: Char) -> String:
        return str(other) + str(self)

    @always_inline
    fn __radd__(self, other: String) -> String:
        return other + str(self)

    @always_inline
    fn to_int(self) -> Int:
        return self.value.to_int()