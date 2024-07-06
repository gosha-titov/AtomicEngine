/// A character that has a type.
///
///     let character = LMCharacter("a", type: .missing)
///     character.rawValue // Character("a")
///     character.type // .missing
///
public struct LMCharacter: Equatable {
    
    /// The corresponding value of this character.
    ///
    ///     let character = LMCharacter("v", type: .correct)
    ///     character.rawValue // Character("v")
    ///
    public let rawValue: Character
    
    /// The type of this character.
    ///
    ///     let character = LMCharacter("t", type: .correct)
    ///     character.type // .correct
    ///
    public var type: CharacterType
    
    /// A boolean value that indicates whether the letter case of this character is correct.
    ///
    /// - Note: `Nil` value means that the letter case does not matter.
    /// This is when the text is leaded to a certain version, for example, to its lowercase version.
    public var hasCorrectLetterCase: Bool?
    
    
    /// Creates a character instance.
    public init(_ rawValue: Character, type: CharacterType, hasCorrectLetterCase: Bool? = nil) {
        self.hasCorrectLetterCase = hasCorrectLetterCase
        self.rawValue = rawValue
        self.type = type
    }
    
}



// MARK: - Behavior Extensions

extension LMCharacter {
    
    /// A boolean value that indicates whether the type of this character is correct.
    @inlinable @inline(__always)
    public var isCorrect: Bool { type == .correct }
    
    /// A boolean value that indicates whether the type of this character is missing.
    @inlinable @inline(__always)
    public var isMissing: Bool { type == .missing }
    
    /// A boolean value that indicates whether the type of this character is extra.
    @inlinable @inline(__always)
    public var isExtra: Bool { type == .extra }
    
    /// A boolean value that indicates whether the type of this character is swapped.
    @inlinable @inline(__always)
    public var isSwapped: Bool {
        return if case .swapped = type { true } else { false }
    }
    
    /// A boolean value that indicates whether the type of this character is misspell.
    @inlinable @inline(__always)
    public var isMisspell: Bool {
        return if case .misspell = type { true } else { false }
    }
    
    /// An uppercase version of this character.
    ///
    ///     let character = LMCharacter("a", type: .misspell("b"))
    ///     character.uppercased // LMCharacter("A", type: .misspell("B"))
    ///
    /// - Note: The uppercase character has no boolean indicator of its letter case correctness.
    @inlinable @inline(__always)
    public var uppercased: LMCharacter {
        let newRawValue = rawValue.uppercased().toCharacter!
        let newType: CharacterType
        switch self.type {
        case .misspell(let correctChar):
            let newCorrectChar = correctChar.uppercased().toCharacter!
            newType = CharacterType.misspell(newCorrectChar)
        default:
            newType = type
        }
        return LMCharacter(newRawValue, type: newType, hasCorrectLetterCase: nil)
    }
    
    /// A lowercase version of this character.
    ///
    ///     let character = LMCharacter("A", type: .misspell("B"))
    ///     character.lowercased // LMCharacter("a", type: .misspell("b"))
    ///
    /// - Note: The lowercase character has no boolean indicator of its letter case correctness.
    @inlinable @inline(__always)
    public var lowercased: LMCharacter {
        let newRawValue = rawValue.lowercased().toCharacter!
        let newType: CharacterType
        switch self.type {
        case .misspell(let correctChar):
            let newCorrectChar = correctChar.lowercased().toCharacter!
            newType = CharacterType.misspell(newCorrectChar)
        default:
            newType = type
        }
        return LMCharacter(newRawValue, type: newType, hasCorrectLetterCase: nil)
    }
    
}


extension LMCharacter: CustomStringConvertible {
    
    /// The textual representation of this character.
    ///
    ///     let char = LMCharacter("s", type: .missing)
    ///     print(char)
    ///     // Prints "Character 's' of type: missing"
    ///
    @inlinable @inline(__always)
    public var description: String {
        let ending: String
        if let hasCorrectLetterCase {
            ending = ", with " + (hasCorrectLetterCase ? "correct" : "wrong") + " letter case"
        } else {
            ending = ""
        }
        return "Character '\(rawValue)' of type: \(type)" + ending
    }
    
}



// MARK: - Character Type

extension LMCharacter {
    
    /// A type that describes a character relative to the original one.
    ///
    /// There are only five types of character: `correct`, `missing`, `swapped`, `misspell` and `extra`.
    public enum CharacterType: Equatable {
        
        /// The type indicating whether a character is correct.
        /// This means that this character is the same as the original one.
        case correct
        
        /// The type indicating whether a character is swapped with another one.
        /// This means that if these two characters are swapped back, they will become correct.
        case swapped(position: SwappedPosition)
        
        /// The type indicating whether a character is missing.
        /// This means that this character is in the original text but is missing in the entered one.
        case missing
        
        /// The type indicating whether a character is extra.
        case extra
        
        /// The type indicating whether a character is misspell, and has associated value that is a correct character.
        case misspell(_ correctChar: Character)
        
    }
    
}


extension LMCharacter.CharacterType {
    
    /// Creates a character type instance with the `.extra` value.
    public init() { self = .extra }
    
}


extension LMCharacter.CharacterType {
    
    /// A type that specifies a character position relative to the correct one.
    ///
    /// This is used when two characters are correct but swapped.
    public enum SwappedPosition: String, Codable, Equatable {
        
        /// A position of a character that is to the left of the correct position.
        case left
        
        /// A position of a character that is to the right of the correct position.
        case right
    }
    
}
