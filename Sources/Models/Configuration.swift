import Foundation

/// A configuration that is applied the creation of the text.
public struct LMConfiguration {
    
    /// The quantity that indicates the required number of correct chars.
    ///
    /// The text is considered incorrect if its count of matching chars is less than this quantity.
    /// If this quantity is `nil` then the check will not be performed.
    /// - Note: The required count of correct chars is counted relative to the accurate text.
    public var requiredQuantityOfCorrectChars: CharQuantity?
    
    /// The quantity that indicates the acceptable number of wrong chars.
    ///
    /// The text is considered incorrect if its count of wrong chars is more than this quantity.
    /// If this quantity is `nil` then the check will not be performed.
    /// - Note: The acceptable count of wrong chars is counted relative to the compared text.
    public var acceptableQuantityOfWrongChars: CharQuantity?
    
    /// The action to be applied to the letter cases of the text.
    ///
    /// All kinds of action:
    ///
    /// - **compare**: Letter cases will be compared. That is, there is a mistake if letter cases do not match.
    ///
    /// + **leadTo(Version)**: Letter cases will be leaded to the given version. That is, there is no mistake if letter cases do not match.
    ///     - **capitalized**: The writing of a word with its first letter in uppercase and the remaining letters in lowercase.
    ///     - **uppercase**: The writing of a word in capital letters.
    ///     - **lowercase**: The writing of a word in small letters.
    ///
    /// If the value is `nil` then letter cases will not be changed. There is no mistake if letter cases do not match.
    public var letterCaseAction: LetterCaseAction?
    
    /// Creates an empty configuration instance.
    public init() {}
}


extension LMConfiguration {
    
    public enum CharQuantity: Equatable {
        
        // MARK: Coefficients
        
        /// A default quantity associated with 100% of chars, that is, the coefficient is `1.0`.
        case all
        
        /// A default quantity associated with 75% of chars, that is, the coefficient is `0.75`.
        case high
        
        /// A default quantity associated with 50% of chars, that is, the coefficient is `0.5`.
        case half
        
        /// A default quantity associated with 25% of chars, that is, the coefficient is `0.25`.
        case low
        
        /// A quantity associated with a certain percentage of chars.
        case coefficient(Double)
        
        /// A double value associated with this quantity.
        internal var coefficient: Double? {
            switch self {
            case .coefficient(let value): return value.clamped(to: 0...1.0)
            case .all:  return 1.0
            case .high: return 0.75
            case .half: return 0.5
            case .low:  return 0.25
            default: return nil
            }
        }
        
        
        // MARK: Numbers
        
        /// A quantity associated with a zero number of chars.
        case zero
        
        /// A quantity associated with a 1 char.
        case one
        
        /// A quantity associated with 2 chars.
        case two
        
        /// A quantity associated with 3 chars.
        case three
        
        /// A quantity associated with a certain number of chars.
        case number(Int)
        
        /// An integer value associated with this quantity.
        internal var number: Int? {
            switch self {
            case .number(let value): return value.clamped(to: 0...)
            case .zero:  return 0
            case .one:   return 1
            case .two:   return 2
            case .three: return 3
            default: return nil
            }
        }
        
        
        // MARK: Methods
        
        /// Returns calculated `Int` value for the given length.
        internal func count(for length: Int, clamped: Bool = false) -> Int {
            guard let coefficient else {
                if clamped { return number!.clamped(to: 0...length) }
                return number!
            }
            if self == .all { return length }
            return (length.toDouble * coefficient).rounded().toInt
        }
        
    }
    
}


extension LMConfiguration {
    
    public enum LetterCaseAction: Equatable {
        
        /// Letter cases will be compared. That is, there is a mistake if letter cases do not match.
        case compare
        
        /// Letter cases will be made in the given version. That is, there is no mistake if letter cases do not match.
        case make(LetterCaseVersion)
        
    }
    
}


extension LMConfiguration {
    
    /// A letter case version that indicates how a text should be written.
    public enum LetterCaseVersion: Equatable {
        
        /// The writing of a text with its first letter in uppercase and the remaining letters in lowercase.
        ///
        ///     let text = "Capitalized"
        ///
        case capitalized
        
        /// The writing of a text in capital letters.
        ///
        ///     let text = "UPPERCASE"
        ///
        case uppercase
        
        /// The writing of a text in small letters.
        ///
        ///     let text = "lowercase"
        ///
        case lowercase
        
    }
    
}
