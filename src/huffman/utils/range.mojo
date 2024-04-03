from builtin.range import _StridedRange

@always_inline
fn reversible_range[reverse: Bool = True, short: Int = 0](end: Int) -> _StridedRange:
    @parameter
    if reverse: return range(end-1, short-1, -1)
    else: return range(0, end-short, 1)

@always_inline
fn reversible_range[reverse: Bool = True, short: Int = 0](start: Int, end: Int) -> _StridedRange:
    @parameter
    if reverse: return range(end-1, (start-1)+short, -1)
    else: return range(start, end-short, 1)