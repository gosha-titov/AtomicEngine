internal extension Array where Element: Numeric {
    
    /// Returns the result of summing the elements of the sequence.
    ///
    ///     let arr = [3, 5, 7]
    ///     arr.sum // 15
    ///
    var sum: Element { reduce(0, +) }
    
    /// Returns the first K elements of this array.
    ///
    ///     let arr = [1, 2, 3, 4, 5]
    ///     arr.first(3) // [1, 2, 3]
    ///
    func first(_ k: Int) -> [Element] {
        let k = k > count ? count : k
        var first = [Element]()
        for i in 0..<k {
            first.append(self[i])
        }
        return first
    }
    
    /// Returns the last K elements of this array.
    ///
    ///     let arr = [1, 2, 3, 4, 5]
    ///     arr.last(3) // [3, 4, 5]
    ///
    func last(_ k: Int) -> [Element] {
        let k = k > count ? count : k
        var last = [Element]()
        for i in (count - k)..<count {
            last.append(self[i])
        }
        return last
    }
    
}
