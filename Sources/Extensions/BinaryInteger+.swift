internal extension BinaryInteger {
    
    /// A Double value converted from this integer.
    ///
    ///     let number = 49
    ///     number.toDouble // 49.0
    ///
    var toDouble: Double { Double(self) }
    
}
