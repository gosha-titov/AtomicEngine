internal extension Array where Element: Numeric {
    
    /// Returns the result of summing the elements of the sequence.
    ///
    ///     let arr = [3, 5, 7]
    ///     arr.sum // 15
    ///
    var sum: Element { reduce(0, +) }
    
}
