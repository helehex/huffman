# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

from testing import assert_equal
from memory import memset_zero
from huffman import Freq, Tree, Book


def main():
    
    # +--- generate frequency table
    var tbl = Freq(path=String("res/important.txt"))
    assert_equal(tbl["N"], 38)
    assert_equal(tbl["n"], 163)

    # +--- generate huffman tree
    var tree = Tree(tbl)

    # +--- generate huffman book
    var book = Book(tree)

    # +--- encode and decode message
    alias message = "never gonna give you up"
    assert_equal(book.decode(book.encode(message)), message)

    var ptr_len = 100
    var ptr = UnsafePointer[UInt8].alloc(ptr_len)
    memset_zero(ptr, ptr_len)
    book.encode(message, ptr, ptr_len)
    assert_equal(book.decode(ptr, ptr_len), message)
    ptr.free()
    