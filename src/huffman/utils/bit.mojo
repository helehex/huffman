# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Implements bit utilities."""


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
# | SIMD repr
# +----------------------------------------------------------------------------------------------+ #
#
@always_inline
fn repr_bits[
    bits: String = "01",
    reverse_bits: Bool = False,
    reverse_simd: Bool = False,
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
            alias div = base ** (i if reverse_bits else bit_width - i - 1)
            result += bits[int(uvalue // div) % base]
    else:
        alias _range = reversible_range[reverse_simd, 1](value.size)

        @parameter
        for i in _range:
            result += repr_bits[bits, reverse_bits](value[i]) + sep
        result += repr_bits[bits, reverse_bits](value[_range.end])

    return result + end


# +----------------------------------------------------------------------------------------------+ #
# | SIMD eval
# +----------------------------------------------------------------------------------------------+ #
#
fn eval_bits[
    type: DType, size: Int, separator: StringLiteral = "\n", symbols: String = "01"
](string: String) raises -> SIMD[type, size]:
    constrained[len(symbols) == 2, "incorrect amount of symbols"]()
    var result: SIMD[type, size] = 0

    @parameter
    if size == 1:
        if len(string) != type.bitwidth():
            raise Error("incorrect number of bits")

        @parameter
        for i in range(type.bitwidth()):
            var char = string[i]
            var bit = char == symbols[1]
            if bit or char == symbols[0]:
                result = (result << 1) + SIMD[type, size](bit)
            else:
                raise Error("unexpected symbol")
    else:
        var strings = string.split(separator)
        if len(strings) != size:
            raise Error("incorrect number of elements")
        for i in range(size):
            result[i] = eval_bits[type, 1, separator, symbols](strings[i])

    return result


# +----------------------------------------------------------------------------------------------+ #
# | SIMD Bit Manipulation
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
# | Memory repr
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
        result += repr_bits[symbols, rbit](Scalar[type].load(ptr, i)) + sep
    if len > 0:
        result += repr_bits[symbols, rbit](Scalar[type].load(ptr, _range.end))
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
    alias size = sizeof[ptr.T]()
    var bytes = ptr.bitcast[UInt8]()
    var result: String = beg
    var _range = reversible_range[rptr, 1](len)
    for i in _range:
        result += repr_bits[symbols, rbit, not rbit, "", "", ""](bytes + (i * size), size) + sep
    if len > 0:
        result += repr_bits[symbols, rbit, not rbit, "", "", ""](bytes + (_range.end * size), size)
    return result + end


# +----------------------------------------------------------------------------------------------+ #
# | Memory Bit Manipulation
# +----------------------------------------------------------------------------------------------+ #
#
fn get_bit[type: DType](ptr: UnsafePointer[Scalar[type]], place: Int) -> Bool:
    var dm = divmod(place, type.bitwidth())
    return get_bit(Scalar[type].load(ptr, dm[0]), dm[1])


fn set_bit[type: DType](ptr: UnsafePointer[Scalar[type]], place: Int, bit: Bool):
    var dm = divmod(place, type.bitwidth())
    Scalar[type].store(ptr, dm[0], set_bit(Scalar[type].load(ptr, dm[0]), dm[1], bit))


fn set_bit[type: DType](ptr: UnsafePointer[Scalar[type]], place: Int):
    var dm = divmod(place, type.bitwidth())
    Scalar[type].store(ptr, dm[0], set_bit(Scalar[type].load(ptr, dm[0]), dm[1]))


fn clear_bit[type: DType](ptr: UnsafePointer[Scalar[type]], place: Int):
    var dm = divmod(place, type.bitwidth())
    Scalar[type].store(ptr, dm[0], clear_bit(Scalar[type].load(ptr, dm[0]), dm[1]))


fn flip_bit[type: DType](ptr: UnsafePointer[Scalar[type]], place: Int):
    var dm = divmod(place, type.bitwidth())
    Scalar[type].store(ptr, dm[0], flip_bit(Scalar[type].load(ptr, dm[0]), dm[1]))
