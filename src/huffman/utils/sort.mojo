# # this general sort complains bout the compare function having wrong type when bound

# fn sort[T: CollectionElement, compare: fn(T,T)->Bool](inout vector: DynamicVector[T]):
#     for i in range(1,len(vector)):
#         var j = i
#         var trans = vector[j]
#         var quest = vector[j - 1]
#         while j > 0 and compare(trans, quest):
#             vector[j] = quest
#             j -= 1
#             quest = vector[j - 1]
#         vector[j] = trans

# fn sort(inout vector: DynamicVector[Leaf]):
#     for i in range(1,len(vector)):
#         var j = i
#         var trans = vector[j]
#         while j > 0 and trans > vector[j - 1]:
#             vector[j] = vector[j - 1]
#             j -= 1
#         vector[j] = trans