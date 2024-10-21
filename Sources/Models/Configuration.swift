import Foundation

/// A configuration that is applied the creation of the text.
///
/// The configuration includes the following rules for the text checking:
///
///     var requiredQuantityOfCorrectChars: CharQuantity
///     var acceptableQuantityOfWrongChars: CharQuantity
///     var letterCaseAction: LetterCaseAction
///
/// Example of a configuration for checking a phrase:
///
///     configuration.requiredQuantityOfCorrectChars // .high
///     configuration.acceptableQuantityOfWrongChars // .three
///     configuration.letterCaseAction // .lowercase
///
public struct LMConfiguration {
    
    /// The quantity that indicates the required number of correct chars.
    ///
    /// The text is considered incorrect if its count of matching chars is less than this quantity.
    /// If this quantity is `none` then the check will not be performed.
    /// - Note: The required count of correct chars is counted relative to the accurate text.
    public var requiredQuantityOfCorrectChars = CharQuantity()
    
    /// The quantity that indicates the acceptable number of wrong chars.
    ///
    /// The text is considered incorrect if its count of wrong chars is more than this quantity.
    /// If this quantity is `none` then the check will not be performed.
    /// - Note: The acceptable count of wrong chars is counted relative to the compared text.
    public var acceptableQuantityOfWrongChars = CharQuantity()
    
    /// The action to be applied to the letter cases of the text.
    ///
    /// All kinds of action:
    ///
    /// - **compare**: Letter cases will be compared. There is a mistake if letter cases do not match.
    /// - **none**:  Letter cases will not be changed. There is no mistake if letter cases do not match.
    ///
    /// Next actions convert letter cases to the specified version, there is no mistake if letter cases do not match:
    /// - **capitalize**: The writing of a word with its first letter in uppercase and the remaining letters in lowercase.
    /// - **uppercase**: The writing of a word in capital letters.
    /// - **lowercase**: The writing of a word in small letters.
    public var letterCaseAction = LetterCaseAction()
    
    
    /// Creates an empty configuration instance.
    public init() {}
    
}



// MARK: - Char Quantity

extension LMConfiguration {
    
    /// A quantity that can be a certain number or coefficient.
    public enum CharQuantity: Equatable {
        
        /// The default quantity associated with zero chars.
        case zero
        
        /// The case indicating that there is no quantity.
        case none
        
        
        // MARK: Coefficients
        
        /// The default quantity associated with 100% of chars, that is, the coefficient is `1.0`.
        case all
        
        /// The default quantity associated with 75% of chars, that is, the coefficient is `0.75`.
        case high
        
        /// The default quantity associated with 50% of chars, that is, the coefficient is `0.5`.
        case half
        
        /// The default quantity associated with 25% of chars, that is, the coefficient is `0.25`.
        case low
        
        /// The quantity associated with a certain percentage of chars.
        case coefficient(Double)
        
        
        // MARK: Numbers
        
        /// The default quantity associated with 1 char.
        case one
        
        /// The default quantity associated with 2 chars.
        case two
        
        /// The default quantity associated with 3 chars.
        case three
        
        /// The quantity associated with a certain number of chars.
        case number(Int)
        
    }
    
}


extension LMConfiguration.CharQuantity {
    
    /// A double value associated with this quantity.
    @inlinable @inline(__always)
    public var coefficient: Double? {
        return switch self {
        case .coefficient(let value): value.clamped(to: 0...1.0)
        case .all:  1.0
        case .high: 0.75
        case .half: 0.5
        case .low:  0.25
        default: nil
        }
    }
    
    /// An integer value associated with this quantity.
    @inlinable @inline(__always)
    public var number: Int? {
        return switch self {
        case .number(let value): value.clamped(to: 0...)
        case .zero:  0
        case .one:   1
        case .two:   2
        case .three: 3
        default: nil
        }
    }
    
    
    // MARK: Methods
    
    /// Returns a calculated `Int` value for the given length.
    @inlinable @inline(__always)
    internal func count(for length: Int, clamped: Bool = false) -> Int? {
        if let coefficient {
            if self == .all { return length }
            return (length.toDouble * coefficient).rounded().toInt
        }
        if let number {
            if clamped { return number.clamped(to: 0...length) }
            return number
        }
        return nil
    }
    
    
    // MARK: Init
    
    /// Creates a quantity with the `.none` value.
    @inlinable @inline(__always)
    public init() {
        self = .none
    }
    
}



// MARK: - Action On Letter Cases

extension LMConfiguration {
    
    /// An action that is applied to the letter cases of the text.
    public enum LetterCaseAction: String, Codable, Equatable {
        
        /// The action determining that letter cases will be compared.
        /// That is, there is a mistake if letter cases do not match.
        case compare
        
        /// The action determining that letter cases will be converted to the capitalized version.
        /// That is, there is no mistake if letter cases do not match.
        ///
        ///     "Capitalized"
        ///
        case capitalize
        
        /// The action determining that letter cases will be converted to the uppercase version.
        /// That is, there is no mistake if letter cases do not match.
        ///
        ///     "UPPERCASE"
        ///
        case uppercase
        
        /// The action determining that letter cases will be converted to the uppercase version.
        /// That is, there is no mistake if letter cases do not match.
        ///
        ///     "lowercase"
        ///
        case lowercase
        
        /// The case indicating that there is no action.
        case none
        
    }
    
}


extension LMConfiguration.LetterCaseAction {
    
    /// Creates an action with the `.none` value.
    @inlinable @inline(__always)
    public init() {
        self = .none
    }
    
}
