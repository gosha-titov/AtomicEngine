public struct AtomicConfiguration {
    
    /// The quantity that indicates the required number of correct chars.
    ///
    /// The atomic text is considered incorrect if its count of matching chars is less than this quantity.
    /// If this quantity is `nil` then the check will not be performed.
    /// - Note: The required count of correct chars is counted relative to the accurate text.
    public var requiredQuantityOfCorrectChars: CharQuantity?
    
    /// The quantity that indicates the acceptable number of wrong chars.
    ///
    /// The atomic text is considered incorrect if its count of wrong chars is more than this quantity.
    /// If this quantity is `nil` then the check will not be performed.
    /// - Note: The acceptable count of wrong chars is counted relative to the compared text.
    public var acceptableQuantityOfWrongChars: CharQuantity?
    
}


extension AtomicConfiguration {
    
    public enum CharQuantity: Equatable {
        
        /// A default quantity associated with 100% of chars, that is, the coefficient is `1.0`.
        case all
        
        /// A default quantity associated with 75% of chars, that is, the coefficient is `0.75`.
        case high
        
        /// A default quantity associated with 50% of chars, that is, the coefficient is `0.5`.
        case half
        
        /// A default quantity associated with 25% of chars, that is, the coefficient is `0.25`.
        case low
        
        /// A default quantity associated with 0% of chars, that is, the coefficient is `0.0`.
        case zero
        
        /// A quantity associated with a certain percentage of chars.
        case other(Double)
        
        /// A double value associated with this quantity.
        internal var coefficient: Double {
            switch self {
            case .other(let value): return value.clamped(to: 0...1.0)
            case .all:  return 1.0
            case .high: return 0.75
            case .half: return 0.5
            case .low:  return 0.25
            case .zero: return 0.0
            }
        }
        
        /// Calculates `Int` value for the given length.
        internal func calculate(for length: Int) -> Int {
            return (length.toDouble * coefficient).rounded().toInt
        }
        
    }
    
}


extension AtomicConfiguration {
    
    public enum LetterCaseAction: Equatable {
        
        /// Letter cases will be compared. That is, there is a mistake if letter cases do not match.
        case compare
        
        /// Letter cases will be leaded to the given version. That is, there is no mistake if letter cases do not match.
        case leadTo(Version)
        
        /// The versoin of writing of a word.
        public enum Version: Equatable {
            
            /// The writing of a word with its first letter in uppercase and the remaining letters in lowercase.
            ///
            ///     let word = "Capitalized"
            ///
            case capitalized
            
            /// The writing of a word in capital letters.
            ///
            ///     let word = "UPPERCASE"
            ///
            case uppercase
            
            /// The writing of a word in small letters.
            ///
            ///     let word = "lowercase"
            ///
            case lowercase
            
        }
        
    }
    
}
