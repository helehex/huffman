# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Implements Sort."""


fn sort_[T: ComparableCollectionElement, compare: fn (T, T) -> Bool](inout list: List[T]):
    for i in range(1, len(list)):
        var j = i
        var sink = list[j]
        while j > 0 and compare(sink, list[j - 1]):
            list[j] = UnsafePointer.address_of(list[j - 1])[]
            j -= 1
        list[j] = sink
