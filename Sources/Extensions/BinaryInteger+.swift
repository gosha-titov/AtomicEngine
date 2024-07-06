internal extension BinaryInteger {
    
    /// A Double value converted from this integer.
    ///
    ///     let number = 49
    ///     number.toDouble // 49.0
    ///
    @inlinable @inline(__always)
    var toDouble: Double { Double(self) }
    
    /// Returns an integer clamped to the given limiting range.
    ///
    ///     let limits = 5...
    ///     3.clamped(to: limits) // 5
    ///     7.clamped(to: limits) // 7
    ///
    @inlinable @inline(__always)
    func clamped(to limits: PartialRangeFrom<Self>) -> Self {
        if self < limits.lowerBound { return limits.lowerBound }
        return self
    }
     
    /// Returns an integer clamped to the given limiting range.
    ///
    ///     let limits = 3..<8
    ///     2.clamped(to: limits) // 3
    ///     5.clamped(to: limits) // 5
    ///     8.clamped(to: limits) // 7
    ///
    @inlinable @inline(__always)
    func clamped(to limits: Range<Self>) -> Self {
        if self < limits.lowerBound { return limits.lowerBound }
        if self >= limits.upperBound { return limits.upperBound - 1 }
        return self
    }
    
    /// Returns an integer clamped to the given limiting range.
    ///
    ///     let limits = 5...8
    ///     3.clamped(to: limits) // 5
    ///     7.clamped(to: limits) // 7
    ///     9.clamped(to: limits) // 8
    ///
    @inlinable @inline(__always)
    func clamped(to limits: ClosedRange<Self>) -> Self {
        if self > limits.upperBound { return limits.upperBound }
        if self < limits.lowerBound { return limits.lowerBound }
        return self
    }
    
}
