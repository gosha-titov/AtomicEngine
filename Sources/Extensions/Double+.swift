internal extension Double {
    
    /// An Int value converted from this double value.
    ///
    ///     let number = 34.56
    ///     number.toInt // 34
    ///
    var toInt: Int { Int(self) }
    
}
