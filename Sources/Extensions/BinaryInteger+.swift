internal extension BinaryInteger {
    
    /// A Double value converted from this integer.
    ///
    ///     let number = 49
    ///     number.toDouble // 49.0
    ///
    var toDouble: Double { Double(self) }
    
    /// Returns an integer clamped to the given limiting range.
    ///
    ///     let limits = 5...
    ///     3.clamped(to: limits) // 5
    ///     7.clamped(to: limits) // 7
    ///
    func clamped(to limits: PartialRangeFrom<Self>) -> Self {
        if self < limits.lowerBound { return limits.lowerBound }
        return self
    }
    
}
