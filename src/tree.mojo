# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Implements tree structures for huffman coding."""

from collections.dict import Dict, DictEntry
from collections.optional import Variant, Optional
from .utils import *


# +----------------------------------------------------------------------------------------------+ #
# | Huffman Tree
# +----------------------------------------------------------------------------------------------+ #
#
struct Tree(Formattable, StringableCollectionElement):
    """Huffman tree."""

    # +------< Data >------+ #
    #
    var chars: String
    var freqs: Int
    var left: UnsafePointer[Self]
    var right: UnsafePointer[Self]
    var _rc: UnsafePointer[Int]

    # +------( Lifecycle )------+ #
    #
    fn __init__(inout self, frequencies: Freq) raises:
        if len(frequencies) < 2:
            raise Error("Not enough symbols")
        var leafs = frequencies.to_leafs()
        var trees = List[Self](capacity=len(leafs))
        var next_tree = 0

        @parameter
        fn pop_min() -> Self:
            if next_tree < len(trees) and (len(leafs) == 0 or trees[next_tree] < leafs[-1]):
                var result = trees[next_tree]
                next_tree += 1
                return result
            else:
                return leafs.pop()

        while len(leafs) + (len(trees) - next_tree) >= 2:
            # This puts smaller frequencies on the right.
            # The other way just inverts the encoding.
            var t1 = pop_min()
            var t2 = pop_min()
            trees.append(Tree(t1, t2))

        self = trees[next_tree]

    fn __init__(inout self, left: Self, right: Self):
        self.chars = left.chars + right.chars
        self.freqs = left.freqs + right.freqs
        self.left = UnsafePointer[Self].alloc(1)
        self.left.init_pointee_copy(left)
        self.right = UnsafePointer[Self].alloc(1)
        self.right.init_pointee_copy(right)
        self._rc = UnsafePointer[Int].alloc(1)
        self._rc.init_pointee_copy(0)

    fn __init__(inout self, leaf: Leaf):
        self.chars = str(leaf.char)
        self.freqs = leaf.freq
        self.left = UnsafePointer[Self]()
        self.right = UnsafePointer[Self]()
        self._rc = UnsafePointer[Int].alloc(1)
        self._rc.init_pointee_copy(0)

    fn __copyinit__(inout self, other: Self):
        self.chars = other.chars
        self.freqs = other.freqs
        self.left = other.left
        self.right = other.right
        self._rc = other._rc
        self._rc[] += 1

    fn __moveinit__(inout self, owned other: Self):
        self.chars = other.chars
        self.freqs = other.freqs
        self.left = other.left
        self.right = other.right
        self._rc = other._rc

    fn __del__(owned self):
        var rc = self._rc[]
        if rc == 0:
            self._rc.destroy_pointee()
            self._rc.free()
            if self.left:
                self.left.destroy_pointee()
                self.left.free()
            if self.right:
                self.right.destroy_pointee()
                self.right.free()
        else:
            self._rc[] = rc - 1

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.format_sequence(self)

    @no_inline
    fn format_to(self, inout writer: Formatter):
        self.format_to[0, 1](writer, "")

    @no_inline
    fn format_to[vgap: Int, hgap: Int](self, inout writer: Formatter, carry: String):
        if self.left and self.right:
            writer.write("[", repr(self.chars), " --> ", self.freqs, "]")
            write_repeated(writer, "\n", carry, BoxChar.vertical, amount=vgap)
            writer.write("\n", carry, BoxChar.vertical_right)
            write_repeated(writer, BoxChar.horizontal, amount=hgap)
            self.left[].format_to[vgap, hgap](writer, rpad(carry + BoxChar.vertical, hgap))
            write_repeated(writer, "\n", carry, BoxChar.vertical, amount=vgap)
            writer.write("\n", carry, BoxChar.upper_right)
            write_repeated(writer, BoxChar.horizontal, amount=hgap)
            self.right[].format_to[vgap, hgap](writer, rpad(carry, hgap + 1))
        else:
            writer.write("[")
            write_ljust(writer, repr(self.chars) + " ", 6, "-")
            writer.write("> ", self.freqs, "]")

    # +------( Comparison )------+ #
    #
    @always_inline
    fn __lt__(self, other: Self) -> Bool:
        return self.freqs < other.freqs or (
            self.freqs == other.freqs and compare(self.chars, other.chars) == 1
        )

    @always_inline
    fn __le__(self, other: Self) -> Bool:
        return self.freqs < other.freqs or (
            self.freqs == other.freqs and compare(self.chars, other.chars) != -1
        )

    @always_inline
    fn __eq__(self, other: Self) -> Bool:
        return self.freqs == other.freqs and self.chars == other.chars

    @always_inline
    fn __gt__(self, other: Self) -> Bool:
        return self.freqs > other.freqs or (
            self.freqs == other.freqs and compare(self.chars, other.chars) == -1
        )

    @always_inline
    fn __ge__(self, other: Self) -> Bool:
        return self.freqs > other.freqs or (
            self.freqs == other.freqs and compare(self.chars, other.chars) != 1
        )

    @always_inline
    fn __ne__(self, other: Self) -> Bool:
        return self.freqs != other.freqs or self.chars != other.chars


# +----------------------------------------------------------------------------------------------+ #
# | Huffman Leaf
# +----------------------------------------------------------------------------------------------+ #
#
@register_passable("trivial")
struct Leaf(Formattable, StringableCollectionElement):
    """Huffman leaf."""

    # +------< Data >------+ #
    #
    var char: Char
    var freq: Int

    # +------( Initialize )------+ #
    #
    fn __init__(inout self, char: Char, freq: Int):
        self.char = char
        self.freq = freq

    fn __init__(inout self, entry: DictEntry[Char, Int]):
        self.char = entry.key
        self.freq = entry.value

    # +------( Format )------+ #
    #
    @no_inline
    fn __str__(self) -> String:
        return String.format_sequence(self)

    @no_inline
    fn format_to(self, inout writer: Formatter):
        writer.write("[")
        write_ljust(writer, repr(self.char) + " ", 6, "-")
        writer.write("> ", self.freq, "]")

    # +------( Comparison )------+ #
    #
    @always_inline
    fn __lt__(self, other: Self) -> Bool:
        return self.freq < other.freq or (self.freq == other.freq and self.char < other.char)

    @always_inline
    fn __le__(self, other: Self) -> Bool:
        return self.freq < other.freq or (self.freq == other.freq and self.char <= other.char)

    @always_inline
    fn __eq__(self, other: Self) -> Bool:
        return self.freq == other.freq and self.char == other.char

    @always_inline
    fn __gt__(self, other: Self) -> Bool:
        return self.freq > other.freq or (self.freq == other.freq and self.char > other.char)

    @always_inline
    fn __ge__(self, other: Self) -> Bool:
        return self.freq > other.freq or (self.freq == other.freq and self.char >= other.char)

    @always_inline
    fn __ne__(self, other: Self) -> Bool:
        return self.freq != other.freq or self.char != other.char
