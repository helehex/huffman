# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #
"""Implements Sort."""


fn sort_[T: ComparableCollectionElement, *, descending: Bool = False](inout list: List[T]):
    @parameter
    fn compare(a: T, b: T) -> Bool:
        @parameter
        if descending:
            return a > b
        else:
            return a < b

    for i in range(1, len(list)):
        var j = i
        var sink = list[j]
        while j > 0 and compare(sink, list[j - 1]):
            UnsafePointer.address_of(list[j])[] = UnsafePointer.address_of(list[j - 1])[]
            j -= 1
        list[j] = sink


# # this general sort complains bout the compare function having wrong type when bound

# fn sort[T: CollectionElement, compare: fn(T,T)->Bool](inout vector: List[T]):
#     for i in range(1,len(vector)):
#         var j = i
#         var trans = vector[j]
#         var quest = vector[j - 1]
#         while j > 0 and compare(trans, quest):
#             vector[j] = quest
#             j -= 1
#             quest = vector[j - 1]
#         vector[j] = trans
