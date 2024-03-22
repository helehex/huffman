"""
Implements tree structures for huffman coding.

This could be done better with more language features.
"""
from collections.dict import Dict, DictEntry
from collections.optional import Variant, Optional
from huffman.utils import *


struct Tree(Stringable, CollectionElement):
    """
    Huffman tree.
    """
    #------< Data >------#
    #
    var chars: String
    var freqs: Int
    var left: AnyPointer[Node]
    var right: AnyPointer[Node]
    var _rc: Pointer[Int]


    #------[ Builder ]------#
    #
    # causes a segfault if you try to move this directly into `__init__()`
    #
    @staticmethod
    fn build(owned frequencies: FrequencyTable) raises -> Self:
        if len(frequencies) < 2: raise Error("Not enough symbols")
        var leafs = frequencies.to_leafs()
        var trees = DynamicVector[Tree](capacity = len(leafs))
        var next_tree = 0

        @parameter
        fn pop_min() -> Node:
            if next_tree < len(trees) and (len(leafs) == 0 or Node(trees[next_tree]) < Node(leafs[len(leafs) - 1])):
                var result = trees[next_tree]
                next_tree += 1
                return result
            else:
                return leafs.pop_back()

        while len(leafs) + (len(trees) - next_tree) >= 2:
            trees.append(Tree(right = pop_min(), left = pop_min())) # This puts smaller frequencies on the right. The other way just inverts the encoding.

        return trees[next_tree]


    #------( Lifetime )------#
    #
    fn __init__(inout self, owned frequencies: FrequencyTable) raises:
        self = Self.build(frequencies)

    fn __init__(inout self, left: Node, right: Node):
        self.chars = left.get_chars() + right.get_chars()
        self.freqs = left.get_freqs() + right.get_freqs()
        self.left = AnyPointer[Node].alloc(1)
        self.left.emplace_value(left)
        self.right = AnyPointer[Node].alloc(1)
        self.right.emplace_value(right)
        self._rc = Pointer[Int].alloc(1)
        self._rc.store(0)

    fn __copyinit__(inout self, other: Self):
        self.chars = other.chars
        self.freqs = other.freqs
        self.left = other.left
        self.right = other.right
        self._rc = other._rc
        self._rc.store(self._rc.load() + 1)

    fn __moveinit__(inout self, owned other: Self):
        self.chars = other.chars
        self.freqs = other.freqs
        self.left = other.left
        self.right = other.right
        self._rc = other._rc

    @always_inline
    fn __del__(owned self):
        var rc = self._rc.load() - 1
        if rc < 0:
            self._rc.free()
            self.left.free()
            self.right.free()
            return
        self._rc.store(rc)


    #------( Get )------#
    #
    fn get_left(self) -> Node: return self.left[]

    fn get_right(self) -> Node: return self.right[]


    #------( Formatting )------#
    #
    fn __str__(self) -> String:
        return self.to_string()

    fn to_string[vgap: Int = 0, hgap: Int = 1](self, carry: String = "") -> String:
        var result = "[" + repr(self.chars) + " --> " + str(self.freqs) + "]"
        result += repeat("\n" + carry + BoxChar.vertical, vgap)
        result += "\n" + carry + BoxChar.vertical_right + repeat(BoxChar.horizontal, hgap) + self.get_left().to_string[vgap, hgap](padr(carry + BoxChar.vertical, hgap))
        result += repeat("\n" + carry + BoxChar.vertical, vgap)
        result += "\n" + carry + BoxChar.upper_right + repeat(BoxChar.horizontal, hgap) + self.get_right().to_string[vgap, hgap](padr(carry, hgap + 1))
        return result


    #------( Comparison )------#
    #
    fn __lt__(self, other: Self) -> Bool:
        return self.freqs < other.freqs or (self.freqs == other.freqs and compare(self.chars, other.chars) == 1)

    fn __le__(self, other: Self) -> Bool:
        return self.freqs < other.freqs or (self.freqs == other.freqs and compare(self.chars, other.chars) != -1)

    fn __eq__(self, other: Self) -> Bool:
        return self.freqs == other.freqs and self.chars == other.chars

    fn __gt__(self, other: Self) -> Bool:
        return self.freqs > other.freqs or (self.freqs == other.freqs and compare(self.chars, other.chars) == -1)

    fn __ge__(self, other: Self) -> Bool:
        return self.freqs > other.freqs or (self.freqs == other.freqs and compare(self.chars, other.chars) != 1)

    fn __ne__(self, other: Self) -> Bool:
        return self.freqs != other.freqs or self.chars != other.chars




@register_passable("trivial")
struct Leaf(Stringable, CollectionElement):
    """
    Huffman leaf.
    """
    #------< Data >------#
    #
    var char: Char
    var freq: Int


    #------( Initialize )------#
    #
    fn __init__(char: Char, freq: Int) -> Self:
        return Self{char: char, freq: freq}

    fn __init__(entry: DictEntry[Char,Int]) -> Self:
        return Self{char: entry.key, freq: entry.value}


    #------( Formatting )------#
    #
    fn __str__(self) -> String:
        return self.to_string()

    fn to_string(self) -> String:
        var repr_char = repr(self.char) + " "
        return "[" + padr["-"](repr_char, 6 - len(repr_char)) + "> " + str(self.freq) + "]"


    #------( Comparison )------#
    #
    fn __lt__(self, other: Self) -> Bool:
        return self.freq < other.freq or (self.freq == other.freq and self.char < other.char)

    fn __le__(self, other: Self) -> Bool:
        return self.freq < other.freq or (self.freq == other.freq and self.char <= other.char)

    fn __eq__(self, other: Self) -> Bool:
        return self.freq == other.freq and self.char == other.char

    fn __gt__(self, other: Self) -> Bool:
        return self.freq > other.freq or (self.freq == other.freq and self.char > other.char)

    fn __ge__(self, other: Self) -> Bool:
        return self.freq > other.freq or (self.freq == other.freq and self.char >= other.char)

    fn __ne__(self, other: Self) -> Bool:
        return self.freq != other.freq or self.char != other.char




struct Node(Stringable, CollectionElement):
    """
    Huffman node. Represents either a `Tree` or `Leaf`.
    """
    #------< Data >------#
    #
    var value: Variant[Tree, Leaf]


    #------( Lifetime )------#
    #
    fn __init__(inout self, value: Variant[Tree, Leaf]):
        self.value = value

    fn __init__(inout self, value: Tree):
        self.value = value

    fn __init__(inout self, value: Leaf):
        self.value = value

    fn __copyinit__(inout self, other: Self):
        self.value = other.value

    fn __moveinit__(inout self, owned other: Self):
        self.value = other.value


    #------( Type )------#
    #
    fn is_tree(self) -> Bool:
        return self.value.isa[Tree]()

    fn is_leaf(self) -> Bool:
        return self.value.isa[Leaf]()

    fn as_tree(self) -> Tree:
        return self.value.get[Tree]()[]

    fn as_leaf(self) -> Leaf:
        return self.value.get[Leaf]()[]


    #------( Get )------#
    #
    fn get_freqs(self) -> Int:
        if self.is_tree():
            return self.as_tree().freqs
        return self.as_leaf().freq

    fn get_chars(self) -> String:
        if self.is_tree():
            return self.as_tree().chars
        return self.as_leaf().char

    fn get_left(self) -> Optional[Node]:
        if self.is_tree():
            return self.as_tree().get_left()
        return None

    fn get_right(self) -> Optional[Node]:
        if self.is_tree():
            return self.as_tree().get_right()
        return None


    #------( Formatting )------#
    #
    fn __str__(self) -> String:
        if self.is_tree():
            return self.as_tree()
        return self.as_leaf()

    fn to_string[vgap: Int = 0, hgap: Int = 1](self, carry: String = "") -> String:
        if self.is_tree():
            return self.as_tree().to_string[vgap, hgap](carry)
        return self.as_leaf().to_string()


    #------( Comparison )------#
    #
    fn __lt__(self, other: Self) -> Bool:
        return self.get_freqs() < other.get_freqs() or (self.get_freqs() == other.get_freqs() and compare(self.get_chars(), other.get_chars()) == 1)

    fn __le__(self, other: Self) -> Bool:
        return self.get_freqs() < other.get_freqs() or (self.get_freqs() == other.get_freqs() and compare(self.get_chars(), other.get_chars()) != -1)

    fn __eq__(self, other: Self) -> Bool:
        return self.get_freqs() == other.get_freqs() and self.get_chars() == other.get_chars()

    fn __gt__(self, other: Self) -> Bool:
        return self.get_freqs() > other.get_freqs() or (self.get_freqs() == other.get_freqs() and compare(self.get_chars(), other.get_chars()) == -1)

    fn __ge__(self, other: Self) -> Bool:
        return self.get_freqs() > other.get_freqs() or (self.get_freqs() == other.get_freqs() and compare(self.get_chars(), other.get_chars()) != 1)

    fn __ne__(self, other: Self) -> Bool:
        return self.get_freqs() != other.get_freqs() or self.get_chars() != other.get_chars()
    