internal extension Double {
    
    /// An Int value converted from this double value.
    ///
    ///     let number = 34.56
    ///     number.toInt // 34
    ///
    @inlinable @inline(__always)
    var toInt: Int { Int(self) }
    
}
