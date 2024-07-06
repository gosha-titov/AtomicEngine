internal extension FloatingPoint {
    
    /// Returns an instance value clamped to the given limiting range.
    ///
    ///     let limits = (5.5)...(8.9)
    ///     (3.3).clamped(to: limits) // 5.5
    ///     (7.1).clamped(to: limits) // 7.1
    ///     (9.3).clamped(to: limits) // 8.9
    ///
    @inlinable @inline(__always)
    func clamped(to limits: ClosedRange<Self>) -> Self {
        if self > limits.upperBound { return limits.upperBound }
        if self < limits.lowerBound { return limits.lowerBound }
        return self
    }
    
}
