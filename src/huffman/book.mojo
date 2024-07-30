# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Implements a huffman book for encoding and decoding messages."""

from collections import Dict
from huffman.utils import *


# +----------------------------------------------------------------------------------------------+ #
# | Huffman Book
# +----------------------------------------------------------------------------------------------+ #
#
struct Book:
    """Huffman book."""

    # +------< Data >------#
    #
    var enc: Dict[Char, String]
    var dec: Dict[String, Char]

    # +------( Lifecycle )------+ #
    #
    fn __init__(inout self, tree: Tree):
        self.enc = Dict[Char, String]()
        self.dec = Dict[String, Char]()
        self._account(tree, "")

    fn _account(inout self, current: Tree, code: String):
        if current.left and current.right:
            self._account(current.left[], code + "0")
            self._account(current.right[], code + "1")
        else:
            self.enc[current.chars] = code
            self.dec[code] = current.chars

    # +------( Encode / Decode )------#
    #
    fn encode(self, string: String) raises -> String:
        var result = String()
        for i in range(len(string)):
            var char = string[i]
            var code = self.enc.find(char)
            if code:
                result += code.take()
            else:
                raise Error("character '" + char + "' was not in vocabulary")
        return result

    fn encode(self, string: String, ptr: UnsafePointer[UInt8], inout ptr_len: Int) raises:
        var bit_len: Int = 0
        var new_len: Int = 0
        var bytes = string.as_bytes()
        bytes.append(0)

        for byte in bytes:
            var char = Char(byte[])
            var code = self.enc.find(char)
            if code:
                var code = code.take()
                for bit in range(len(code)):
                    bit_len += 1
                    var dm = divmod(bit_len, 8)
                    new_len = dm[0]
                    if new_len < ptr_len:
                        set_bit[DType.uint8](ptr, bit_len - 1, code[bit] == "1")
                    else:
                        raise Error("buffer overflow")
            else:
                raise Error("character '" + char + "' was not in vocabulary")
        ptr_len = new_len + 1

    fn decode(self, string: String) raises -> String:
        var result = String()
        var code = String()
        for i in range(len(string)):
            code += string[i]
            var char = self.dec.find(code)
            if char:
                result += str(char.take())
                code = String()
        return result

    fn decode(self, ptr: UnsafePointer[UInt8], ptr_len: Int) raises -> String:
        var result: String = ""
        var next_bit: Int = 0
        var next_byte: Int = 0
        var next_char: Optional[Char] = None

        @parameter
        fn get_next_char() raises -> Bool:
            var code: String = ""
            next_char = None
            while not next_char:
                if next_byte >= ptr_len:
                    raise Error("buffer overflow")
                code += "1" if get_bit[DType.uint8](ptr, next_bit) else "0"
                next_char = self.dec.find(code)
                next_bit += 1
                next_byte = next_bit // 8
            return next_char.unsafe_value() != "\0"

        while get_next_char():
            result += str(next_char.take())
        return result
