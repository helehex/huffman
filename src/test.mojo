from pathlib import Path
from benchmark import *
from huffman import *
from huffman.utils import *


fn main() raises:
    test_huffman()


fn test_huffman() raises:

    #--- generate huffman book ---#
    #
    var path = Path("res/important.txt")
    var tbl = FrequencyTable(path)
    # var vec = tbl.to_leafs()
    # sort[descending = True](vec)
    # print(tbl)
    # print_(vec)
    var tree = Tree(tbl)
    var book = Book(tree)
    print(tree)
    print()

    #--- encode and decode message ---#
    #
    var message = "We're no strangers to love"
    var ptr_len = 100
    var ptr = DTypePointer[DType.int8].alloc(ptr_len)
    memset_zero(ptr, ptr_len)
    print("message:", message)
    print("bytes:  ", repr_bits[" ", reverse_bits = True](message.data(), len(message) + 1))
    print()
    book.encode(message, ptr, ptr_len)
    print("encoded:", repr(_str[" "](ptr, ptr_len)))
    print("bytes:  ", repr_bits[" ", reverse_bits = True](ptr, ptr_len))
    print()
    print("decoded:", book.decode(ptr, ptr_len))
    print()
    print(len(message), "vs", ptr_len)
    print("saved", len(message) - ptr_len, "bytes")
    ptr.free()


fn test_bit():
    var val = SIMD[DType.int8,4](-86, 50, -1, 0)
    var bits = repr_bits[" ", "ol", True, True](val)
    print(val)
    print(bits)
    try:
        print(eval_bits[DType.int8, 4, " ", "ol"](bits))
    except e:
        print(e)


fn test_bit_ptr():
    alias type = DType.int8
    alias len = 10
    alias last = len*type.bitwidth() - 1
    var ptr = DTypePointer[type].alloc(len)
    memset_zero(ptr, len)
    # ptr.store(0,1)
    set_bit(ptr, last)
    set_bit(ptr, last - 2)
    # clear_bit(ptr, last)
    # set_bit(ptr, len*type.bitwidth() - 2, False)
    set_bit(ptr, 0, True)
    set_bit(ptr, 1, True)
    #flip_bit(ptr, 2)
    flip_bit(ptr, 30)
    print(repr_bits(ptr, len))
    print(get_bit(ptr, 0), get_bit(ptr, 1), get_bit(ptr, 2), get_bit(ptr, 3), get_bit(ptr, 4))
    ptr.free()


fn _str[separator: StringLiteral = ""](ptr: DTypePointer[DType.int8], len: Int) -> String:
    var result: String = ""
    for i in range(len - 1): result += Char(ptr.load(i)) + separator
    return result + Char(ptr.load(len - 1))

fn _print(value: List[Leaf]):
    for i in range(len(value)): print(value[i])