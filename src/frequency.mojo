# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Implements a character frequency table for huffman coding."""

from pathlib import Path
from collections import Dict
from .utils import *


# +----------------------------------------------------------------------------------------------+ #
# | Huffman Frequency Table
# +----------------------------------------------------------------------------------------------+ #
#
struct Freq(Sized, Writable, StringableCollectionElement):
    """
    A table containing the frequency of characters in a `String` or `Path`.

    Automatically includes the null character with a frequency of 1. (used to mark the end of a string)
    """

    # +------< Data >------+ #
    #
    var _data: Dict[Char, Int]

    # +------( Lifecycle )------+ #
    #
    fn __init__(inout self, string: String):
        self._data = Dict[Char, Int]()
        self.account(string)

    fn __init__(inout self, path: Path) raises:
        self._data = Dict[Char, Int]()
        self.account(path)

    fn __copyinit__(inout self, other: Self):
        self._data = other._data

    fn __moveinit__(inout self, owned other: Self):
        self._data = other._data^

    fn account(inout self, path: Path) raises:
        self.account(path.read_text())

    fn account(inout self, string: String):
        for i in range(len(string)):
            var char = string[i]
            self._data[char] = self._data.find(char).or_else(0) + 1
        self._data[Char()] = 1

    # +------( Convert )------+ #
    #
    fn to_leafs(self) -> List[Leaf]:
        """Return a list of leafs sorted by frequency."""
        var result = List[Leaf](capacity=len(self))
        for item in self._data.items():
            result.append(item[])
        sort_[Leaf, Leaf.__gt__](result)
        return result

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.write(self)

    @no_inline
    fn write_to[WriterType: Writer, //](self, inout writer: WriterType):
        for item in self._data.items():
            writer.write(Leaf(item[]), "\n")

    # +------( Subscript )------+ #
    @always_inline
    fn __getitem__(self, item: Char) raises -> Int:
        return self._data[item]

    # +------( Unary )------+ #
    #
    @always_inline
    fn __len__(self) -> Int:
        return len(self._data)
