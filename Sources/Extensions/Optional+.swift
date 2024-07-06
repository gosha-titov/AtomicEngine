internal extension Optional {
    
    // MARK: Properties
        
    /// A Boolean value that indicates whether this optional object is `nil`.
    ///
    ///     var age: Int?
    ///     age.isNil // true
    ///
    @inlinable @inline(__always)
    var isNil: Bool { self == nil }
    
    /// A Boolean value that indicates whether this optional object is not `nil`.
    ///
    ///     var name: String? = "gosha"
    ///     name.hasValue // true
    ///
    @inlinable @inline(__always)
    var hasValue: Bool { self != nil }
    
}


internal extension Optional where Wrapped: Collection {
    
    /// A Boolean value that indicates whether the optional object is empty or `nil`.
    ///
    ///     var str: String? = nil
    ///     str.isNilOrEmpty // true
    ///
    ///     var array: [Int]? = []
    ///     array.isNilOrEmpty // true
    ///
    ///     var dict: [Int: String]? = [12: "34"]
    ///     dict.isNilOrEmpty // false
    ///
    @inlinable @inline(__always)
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
    
}
