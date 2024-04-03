"""Sort."""

trait SortableCollectionElement(Sortable, CollectionElement): pass

trait Sortable:
    fn __lt__(self, rhs: Self) -> Bool: ...
    fn __gt__(self, rhs: Self) -> Bool: ...

fn sort[T: SortableCollectionElement, *, descending: Bool = False](inout vector: List[T]):
    @parameter
    fn compare(a: T, b: T) -> Bool:
        @parameter
        if descending: return a > b
        else: return a < b

    for i in range(1,len(vector)):
        var j = i
        var sink = vector[j]
        while j > 0 and compare(sink, vector[j - 1]):
            vector[j] = vector[j - 1]
            j -= 1
        vector[j] = sink


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