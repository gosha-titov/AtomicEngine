internal extension Array where Element: Numeric {
    
    /// Returns the result of summing the elements of the sequence.
    ///
    ///     let arr = [3, 5, 7]
    ///     arr.sum // 15
    ///
    @inlinable @inline(__always) 
    var sum: Element { reduce(0, +) }
    
    /// Returns the first K elements of this array.
    ///
    ///     let arr = [1, 2, 3, 4, 5]
    ///     arr.first(3) // [1, 2, 3]
    ///
    @inlinable @inline(__always) 
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
    @inlinable @inline(__always) 
    func last(_ k: Int) -> [Element] {
        let k = k > count ? count : k
        var last = [Element]()
        for i in (count - k)..<count {
            last.append(self[i])
        }
        return last
    }
    
}


internal extension Array where Element: LosslessStringConvertible {
    
    /// Returns a string by converting the elements of the sequence to strings and concatenating them, adding the given separator between each element.
    ///
    ///     [1.2, 3.4, 5.6].toString(separator: " ") // "1.2 3.4 5.6"
    ///     [1, 2, 3].toString(separator: ", ") // "1, 2, 3"
    ///
    /// - Parameter separator: A string to insert between each of the elements in this sequence. The default separator is an empty string.
    @inlinable @inline(__always)
    func toString(separator: String = "") -> String {
        return map { String($0) }.joined(separator: separator)
    }
    
}
