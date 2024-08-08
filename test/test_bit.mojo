# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

from testing import assert_equal
from huffman.utils.bit import *


def main():
    test_repr_bits()
    test_eval_bits()

def test_repr_bits():
    assert_equal(repr_bits(Scalar[DType.uint8](0)), "00000000")
    assert_equal(repr_bits(Scalar[DType.uint8](1)), "00000001")
    assert_equal(repr_bits(Scalar[DType.uint8](5)), "00000101")
    assert_equal(repr_bits(Scalar[DType.int8](-1)), "11111111")
    assert_equal(repr_bits[rbit = True](Scalar[DType.uint8](5)), "10100000")
    assert_equal(repr_bits[rbit = True](SIMD[DType.uint16, 2](5, 6)), "1010000000000000\n0110000000000000")
    assert_equal(repr_bits[rbit = True, rvec = True](SIMD[DType.uint16, 2](5, 6)), "0110000000000000\n1010000000000000")

def test_eval_bits():
    assert_equal(eval_bits[DType.uint8, 1]("00000000"), Scalar[DType.uint8](0))
    assert_equal(eval_bits[DType.uint8, 1]("00000001"), Scalar[DType.uint8](1))
    assert_equal(eval_bits[DType.uint8, 1]("00000101"), Scalar[DType.uint8](5))
    assert_equal(eval_bits[DType.int8, 1]("11111111"), Scalar[DType.int8](-1))
    # assert_equal(eval_bits[DType.int8, 1, rbit = True]("10100000"), Scalar[DType.uint8](5))
    # assert_equal(eval_bits[DType.int8, 1, rbit = True]("1010000000000000\n110000000000000"), SIMD[DType.uint16, 2](5, 6))
    # assert_equal(eval_bits[DType.int8, 1, rbit = True]("1010000000000000\n110000000000000"), SIMD[DType.uint16, 2](5, 6))