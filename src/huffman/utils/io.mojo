trait StringableCollectionElement(Stringable, CollectionElement): pass

#------ List[StringableCollectionElement] to String
#
fn str_[T: StringableCollectionElement, separator: StringLiteral = "\n", before: StringLiteral = "", after: StringLiteral = "\n"](list: List[T]) -> String:
    var result: String = before
    var end: Int = len(list) - 1
    for i in range(end): result += str(list[i]) + separator
    if len(list) > 0: result += str(list[end])
    return result + after
    
fn print_[T: StringableCollectionElement](list: List[T]): print(str_(list))