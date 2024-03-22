from math import divmod


#------ SIMD ------#

@always_inline
fn repr_bits[separator: StringLiteral = "\n", symbols: String = "01", reverse_bits: Bool = False, reverse_simd: Bool = False](value: SIMD) -> String:
    constrained[len(symbols) == 2, "incorrect amount of symbols"]()
    var result: String = ""

    @parameter
    if value.size == 1:
        alias _range = reversible_range[not reverse_bits](value.element_type.bitwidth())
        @unroll
        for i in _range: result += symbols[((value >> i) % 2).to_int()]
    else:
        alias _range = reversible_range[reverse_simd, 1](value.size)
        @unroll
        for i in _range: result += repr_bits[symbols=symbols, reverse_bits=reverse_bits](value[i]) + separator
        result += repr_bits[symbols=symbols, reverse_bits=reverse_bits](value[_range.end])

    return result


fn eval_bits[type: DType, size: Int, separator: StringLiteral = "\n", symbols: String = "01"](string: String) raises -> SIMD[type,size]:
    constrained[len(symbols) == 2, "incorrect amount of symbols"]()
    var result: SIMD[type,size] = 0

    @parameter
    if size == 1:
        if len(string) != type.bitwidth(): raise Error("incorrect number of bits")
        @unroll
        for i in range(type.bitwidth()):
            var char = string[i]
            var bit = (char == symbols[1])
            if bit or char == symbols[0]: result = ((result << 1) + bit)
            else: raise Error("unexpected symbol")
    else:
        var strings = string.split(separator)
        if len(strings) != size: raise Error("incorrect number of elements")
        for i in range(size): result[i] = eval_bits[type, 1, separator, symbols](strings[i])

    return result


fn get_bit[type: DType, size: Int](value: SIMD[type,size], place: SIMD[type,size]) -> SIMD[DType.bool,size]:
    return (value >> place) % 2 == 1

fn set_bit[type: DType, size: Int](value: SIMD[type,size], place: SIMD[type,size], bit: SIMD[DType.bool,size]) -> SIMD[type,size]:
    return (value & ~(1 << place)) | (bit.cast[type]() << place)

fn set_bit[type: DType, size: Int](value: SIMD[type,size], place: SIMD[type,size]) -> SIMD[type,size]:
    return value | (1 << place)

fn clear_bit[type: DType, size: Int](value: SIMD[type,size], place: SIMD[type,size]) -> SIMD[type,size]:
    return value & ~(1 << place)

fn flip_bit[type: DType, size: Int](value: SIMD[type,size], place: SIMD[type,size]) -> SIMD[type,size]:
    return value ^ (1 << place)




#------ DTypePointer ------#

fn repr_bits[separator: StringLiteral = " ", symbols: String = "01", reverse_bits: Bool = False, reverse_ptr: Bool = False](ptr: DTypePointer, len: Int) -> String:
    var result: String = ""
    var _range = reversible_range[reverse_ptr, 1](len)
    for i in _range: result += repr_bits[symbols=symbols, reverse_bits=reverse_bits](ptr.load(i)) + separator
    return result + repr_bits[symbols=symbols, reverse_bits=reverse_bits](ptr.load(_range.end))

fn get_bit[type: DType](ptr: DTypePointer[type], place: Int) -> Bool:
    var dm = divmod(place, type.bitwidth())
    return get_bit(ptr.load(dm[0]), dm[1])

fn set_bit[type: DType](ptr: DTypePointer[type], place: Int, bit: Bool):
    var dm = divmod(place, type.bitwidth())
    ptr.store(dm[0], set_bit(ptr.load(dm[0]), dm[1], bit))

fn set_bit[type: DType](ptr: DTypePointer[type], place: Int):
    var dm = divmod(place, type.bitwidth())
    ptr.store(dm[0], set_bit(ptr.load(dm[0]), dm[1]))

fn clear_bit[type: DType](ptr: DTypePointer[type], place: Int):
    var dm = divmod(place, type.bitwidth())
    ptr.store(dm[0], clear_bit(ptr.load(dm[0]), dm[1]))

fn flip_bit[type: DType](ptr: DTypePointer[type], place: Int):
    var dm = divmod(place, type.bitwidth())
    ptr.store(dm[0], flip_bit(ptr.load(dm[0]), dm[1]))