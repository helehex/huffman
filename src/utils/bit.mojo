# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Implements bit utilities."""

from memory import bitcast
from sys import sizeof


@always_inline
fn _bitwidth[type: DType, base: Int = 2]() -> Int:
    constrained[base > 1, "base must be greater than one"]()

    @parameter
    if base == 2:
        return type.bitwidth()
    else:
        var start = Scalar[to_uint[type]()].MAX
        var count = 0
        while start > 0:
            start //= base
            count += 1
        return count
        # alias ln2 = log(Float64(2))
        # return int(ceil(ln2*type.bitwidth())/log(Float64(base)))


@always_inline
fn to_uint[type: DType]() -> DType:
    alias bitwidth = type.bitwidth()

    @parameter
    if bitwidth == 8:
        return DType.uint8
    elif bitwidth == 16:
        return DType.uint16
    elif bitwidth == 32:
        return DType.uint32
    else:
        return DType.uint64


# +----------------------------------------------------------------------------------------------+ #
# | SIMD to Bits
# +----------------------------------------------------------------------------------------------+ #
#
@always_inline
fn repr_bits[
    bits: String = "01",
    rbit: Bool = False,
    rvec: Bool = False,
    beg: StringLiteral = "",
    sep: StringLiteral = "\n",
    end: StringLiteral = "",
](value: SIMD) -> String:
    var result: String = beg

    @parameter
    if value.size == 1:
        alias base: Int = len(bits)
        alias bit_width = _bitwidth[value.type, base]()
        var uvalue = bitcast[to_uint[value.type](), 1](value)

        @parameter
        for i in range(bit_width):
            alias div = base ** (i if rbit else bit_width - i - 1)
            result += bits[int(uvalue // div) % base]
    else:
        alias _range = reversible_range[rvec, 1](value.size)

        @parameter
        for i in _range:
            result += repr_bits[bits, rbit](value[i]) + sep
        result += repr_bits[bits, rbit](value[_range.end])

    return result + end


# +----------------------------------------------------------------------------------------------+ #
# | Bits to SIMD
# +----------------------------------------------------------------------------------------------+ #
#
fn eval_bits[
    type: DType, size: Int, separator: StringLiteral = "\n", bits: String = "01"
](string: String) raises -> SIMD[type, size]:
    constrained[len(bits) == 2, "incorrect amount of symbols"]()
    var result: SIMD[type, size] = 0

    @parameter
    if size == 1:
        if len(string) != type.bitwidth():
            raise Error("incorrect number of bits")

        @parameter
        for i in range(type.bitwidth()):
            var char = string[i]
            var bit = char == bits[1]
            if bit or char == bits[0]:
                result = (result << 1) + SIMD[type, size](bit)
            else:
                raise Error("unexpected symbol")
    else:
        var strings = string.split(separator)
        if len(strings) != size:
            raise Error("incorrect number of elements")
        for i in range(size):
            result[i] = eval_bits[type, 1, separator, bits](strings[i])

    return result


# +----------------------------------------------------------------------------------------------+ #
# | Bit Manipulate SIMD
# +----------------------------------------------------------------------------------------------+ #
#
fn get_bit[
    type: DType, size: Int
](value: SIMD[type, size], place: SIMD[type, size]) -> SIMD[DType.bool, size]:
    return (value >> place) % 2 == 1


fn set_bit[
    type: DType, size: Int
](value: SIMD[type, size], place: SIMD[type, size], bit: SIMD[DType.bool, size]) -> SIMD[
    type, size
]:
    return (value & ~(1 << place)) | (bit.cast[type]() << place)


fn set_bit[
    type: DType, size: Int
](value: SIMD[type, size], place: SIMD[type, size]) -> SIMD[type, size]:
    return value | (1 << place)


fn clear_bit[
    type: DType, size: Int
](value: SIMD[type, size], place: SIMD[type, size]) -> SIMD[type, size]:
    return value & ~(1 << place)


fn flip_bit[
    type: DType, size: Int
](value: SIMD[type, size], place: SIMD[type, size]) -> SIMD[type, size]:
    return value ^ (1 << place)


# +----------------------------------------------------------------------------------------------+ #
# | String to Bits
# +----------------------------------------------------------------------------------------------+ #
#
fn repr_bits[
    symbols: String = "01",
    rbit: Bool = False,
    rptr: Bool = False,
    beg: StringLiteral = "",
    sep: StringLiteral = "\n",
    end: StringLiteral = "",
](string: String) -> String:
    return repr_bits[symbols=symbols, rbit=rbit, rptr=rptr, beg=beg, sep=sep, end=end](
        string.unsafe_ptr(), len(string)
    )


# +----------------------------------------------------------------------------------------------+ #
# | Memory to Bits
# +----------------------------------------------------------------------------------------------+ #
#
fn repr_bits[
    type: DType, //,
    symbols: String = "01",
    rbit: Bool = False,
    rptr: Bool = False,
    beg: StringLiteral = "",
    sep: StringLiteral = "\n",
    end: StringLiteral = "",
](ptr: UnsafePointer[Scalar[type], _, _], len: Int) -> String:
    var result: String = beg
    var _range = reversible_range[rptr, 1](len)
    for i in _range:
        result += repr_bits[symbols, rbit](ptr.load(i)) + sep
    if len > 0:
        result += repr_bits[symbols, rbit](ptr.load(_range.end))
    return result + end


fn repr_bits[
    T: AnyType, //,
    symbols: String = "01",
    rbit: Bool = False,
    rptr: Bool = False,
    beg: StringLiteral = "",
    sep: StringLiteral = "\n",
    end: StringLiteral = "",
](ptr: UnsafePointer[_, _, _], len: Int) -> String:
    alias size = sizeof[ptr.type]()
    var bytes = ptr.bitcast[UInt8]()
    var result: String = beg
    var _range = reversible_range[rptr, 1](len)
    for i in _range:
        result += repr_bits[symbols, rbit, not rbit, "", "", ""](bytes + (i * size), size) + sep
    if len > 0:
        result += repr_bits[symbols, rbit, not rbit, "", "", ""](bytes + (_range.end * size), size)
    return result + end


# +----------------------------------------------------------------------------------------------+ #
# | Bit Manipulate Memory
# +----------------------------------------------------------------------------------------------+ #
#
fn get_bit[type: DType](ptr: UnsafePointer[Scalar[type]], place: Int) -> Bool:
    var dm = divmod(place, type.bitwidth())
    return get_bit(ptr.load(dm[0]), dm[1])


fn set_bit[type: DType](ptr: UnsafePointer[Scalar[type]], place: Int, bit: Bool):
    var dm = divmod(place, type.bitwidth())
    ptr.store(dm[0], set_bit(ptr.load(dm[0]), dm[1], bit))


fn set_bit[type: DType](ptr: UnsafePointer[Scalar[type]], place: Int):
    var dm = divmod(place, type.bitwidth())
    ptr.store(dm[0], set_bit(ptr.load(dm[0]), dm[1]))


fn clear_bit[type: DType](ptr: UnsafePointer[Scalar[type]], place: Int):
    var dm = divmod(place, type.bitwidth())
    ptr.store(dm[0], clear_bit(ptr.load(dm[0]), dm[1]))


fn flip_bit[type: DType](ptr: UnsafePointer[Scalar[type]], place: Int):
    var dm = divmod(place, type.bitwidth())
    ptr.store(dm[0], flip_bit(ptr.load(dm[0]), dm[1]))
