import Foundation

internal extension String {
    
    /// An optional character converted from this string.
    ///
    ///     let str = "A"
    ///     str.toCharacter! // Character("A")
    ///
    @inlinable @inline(__always)
    var toCharacter: Character? { Character(self) }
    
    // MARK: Properties
        
    /// A NSAttributedString value converted from this string value.
    ///
    ///     let attributedString = "text".toNSAttributedString
    ///
    @inlinable @inline(__always)
    var toNSAttributedString: NSAttributedString {
        return NSAttributedString(string: self)
    }
    
    /// Returns a string containing characters this string and the given string have in common,
    /// starting from the ending of each up to the first characters that aren’t equivalent.
    ///
    ///     let str1 = "abcde"
    ///     let str2 = "abde"
    ///     str1.commonSuffix(with: str2) // "de"
    ///
    @inlinable @inline(__always)
    func commonSuffix(with str: String) -> String {
        var suffix = String()
        let min = min(count, str.count)
        let str1 = self.last(min)
        let str2 = str .last(min)
        for (char1, char2) in zip(str1, str2).reversed() {
            if char1 == char2 { suffix += char1 }
            else { break }
        }
        return String(suffix.reversed())
    }
    
    /// Returns the first K elements of the string.
    ///
    ///     let str = "abcde"
    ///     str.first(3) // "abc"
    ///
    @inlinable @inline(__always)
    func first(_ k: Int) -> String {
        let k = k > count ? count : k
        var first = String()
        for i in 0..<k {
            first.append(self[i])
        }
        return first
    }
    
    /// Returns the last K elements of the string.
    ///
    ///     let str = "abcde"
    ///     str.last(3) // "cde"
    ///
    @inlinable @inline(__always)
    func last(_ k: Int) -> String {
        let k = k > count ? count : k
        var last = String()
        for i in (count - k)..<count {
            last.append(self[i])
        }
        return last
    }
    
    /// Leads the string to capitalized.
    ///
    ///     var str = "woRd"
    ///     str.capitalize() // "Word"
    ///
    @inlinable @inline(__always)
    mutating func capitalize() -> Void {
        self = capitalized
    }
    
    /// Leads the string to uppercase.
    ///
    ///     var str = "WorD"
    ///     str.uppercase() // "WORD"
    ///
    @inlinable @inline(__always)
    mutating func uppercase() -> Void {
        self = uppercased()
    }
    
    /// Leads the string to lowercase.
    ///
    ///     var str = "WorD"
    ///     str.lowercase() // "word"
    ///
    @inlinable @inline(__always)
    mutating func lowercase() -> Void {
        self = lowercased()
    }
    
    
    // MARK: Operators
    
    @inlinable @inline(__always)
    static func += (lhs: inout String, rhs: Character) -> Void {
        lhs = lhs + String(rhs)
    }
    
    @inlinable @inline(__always)
    static func + (lhs: String, rhs: Character) -> String {
        return lhs + String(rhs)
    }
    
    @inlinable @inline(__always)
    static func + (lhs: Character, rhs: String) -> String {
        return String(lhs) + rhs
    }
    
    
    // MARK: Subscripts
    
    @inlinable @inline(__always)
    subscript(bounds: ClosedRange<Int>) -> String {
        let lowerBound = index(startIndex, offsetBy: bounds.lowerBound)
        let upperBound = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[lowerBound...upperBound])
    }

    @inlinable @inline(__always)
    subscript(bounds: Range<Int>) -> String {
        let lowerBound = index(startIndex, offsetBy: bounds.lowerBound)
        let upperBound = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[lowerBound..<upperBound])
    }

    @inlinable @inline(__always)
    subscript(bounds: PartialRangeFrom<Int>) -> String {
        let lowerBound = index(startIndex, offsetBy: bounds.lowerBound)
        return String(self[lowerBound...])
    }

    @inlinable @inline(__always)
    subscript(bounds: PartialRangeUpTo<Int>) -> String {
        let upperBound = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[..<upperBound])
    }

    @inlinable @inline(__always)
    subscript(bounds: PartialRangeThrough<Int>) -> String {
        let upperBound = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[...upperBound])
    }
    
    @inlinable @inline(__always)
    subscript(offset: Int) -> Character {
        let index = index(startIndex, offsetBy: offset)
        return self[index]
    }
    
    @inlinable @inline(__always)
    subscript(safe offset: Int) -> Character? {
        guard (0..<count).contains(offset) else { return nil }
        return self[offset]
    }
    
}
