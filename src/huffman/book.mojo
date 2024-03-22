"""
Implements a huffman book for encoding and decoding messages.
"""
from collections import Dict
from math import divmod
from huffman.utils import *


struct Book:
    """
    Huffman book.
    """
    #------< Data >------#
    #
    var enc: Dict[Char, String]
    var dec: Dict[String, Char]


    #------( Lifetime )------#
    #
    fn __init__(inout self, tree: Tree):
        self.enc = Dict[Char, String]()
        self.dec = Dict[String, Char]()
        self._account(tree, "")

    fn _account(inout self, current: Node, code: String):
        if current.is_tree():
            var tree = current.as_tree()
            self._account(tree.get_left(), code + "0")
            self._account(tree.get_right(), code + "1")
        else:
            var leaf = current.as_leaf()
            self.enc[leaf.char] = code
            self.dec[code] = leaf.char


    #------( Encode / Decode )------#
    #
    fn encode(self, string: String) raises -> String:
        var result = String()
        for i in range(len(string)):
            var char = string[i]
            var code = self.enc.find(char)
            if code: result += code.take()
            else: raise Error("character '" + char + "' was not in vocabulary")
        return result

    fn encode(self, string: String, ptr: DTypePointer[DType.int8], inout ptr_len: Int) raises:
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
                    if new_len < ptr_len: set_bit[DType.int8](ptr, bit_len - 1, code[bit] == "1")
                    else: raise Error("buffer overflow")
            else: raise Error("character '" + char + "' was not in vocabulary")
        ptr_len = new_len + 1

    fn decode(self, string: String) raises -> String:
        var result = String()
        var code = String()
        for i in range(len(string)):
            code += string[i]
            var char = self.dec.find(code)
            if char:
                result += char.take()
                code = String()
        return result

    fn decode(self, ptr: DTypePointer[DType.int8], ptr_len: Int) raises -> String:
        var result: String = ""
        var next_bit: Int = 0
        var next_byte: Int = 0
        var next_char: Optional[Char] = None

        @parameter
        fn get_next_char() raises -> Bool:
            var code: String = ""
            next_char = None
            while not next_char:
                if next_byte >= ptr_len: raise Error("buffer overflow")
                code += "1" if get_bit[DType.int8](ptr, next_bit) else "0"
                next_char = self.dec.find(code)
                next_bit += 1
                next_byte = next_bit // 8
            return next_char.take() != "\0"

        while get_next_char(): result += next_char.take()
        return result
