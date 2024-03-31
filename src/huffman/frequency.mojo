"""
Implements a character frequency table for huffman coding.
"""
from pathlib import Path
from collections import Dict
from huffman.utils import *


struct FrequencyTable(Stringable, Sized):
    """
    A table containing the frequency of characters in a `String` or `Path`.

    Automatically includes the null character with a frequency of 1. (used to mark the end of a string)
    """
    #------< Data >------#
    #
    var _data: Dict[Char, Int]


    #------( Lifetime )------#
    #
    fn __init__(inout self, string: String):
        self._data = Dict[Char, Int]()
        self.account(string)

    fn __init__[__:None=None](inout self, path: Path) raises:
        self._data = Dict[Char, Int]()
        self.account(path)

    fn __copyinit__(inout self, other: Self):
        self._data = other._data

    fn __moveinit__(inout self, owned other: Self):
        self._data = other._data

    fn account(inout self, path: Path) raises:
        self.account(path.read_text())

    fn account(inout self, string: String):
        for i in range(len(string)):
            var char = string[i]
            self._data[char] = self._data.find(char).or_else(0) + 1
        self._data[None] = 1


    #------( Formatting )------#
    #
    fn __str__(self) -> String:
        var result: String = ""
        for item in self._data.items():
            result += str(Leaf(item[])) + "\n"
        return result

    fn __len__(self) -> Int:
        return len(self._data)


    #------( Convert )------#
    #
    fn to_leafs(self) -> List[Leaf]:
        """Return a list of leafs sorted by frequency."""
        var result = List[Leaf](capacity = len(self))
        for item in self._data.items(): result.append(item[])
        sort(result)
        return result




# used to sort leafs, see utils.sort
fn sort(inout vector: List[Leaf]):
    for i in range(1,len(vector)):
        var j = i
        var trans = vector[j]
        while j > 0 and trans > vector[j - 1]:
            vector[j] = vector[j - 1]
            j -= 1
        vector[j] = trans