/// A character that has a type.
///
///     let character = THCharacter("a", type: .missing)
///     character.rawValue // Character("a")
///     character.type // .missing
///
public struct THCharacter: Equatable {
    
    /// The corresponding value of this character.
    ///
    ///     let character = THCharacter("v", type: .correct)
    ///     character.rawValue // Character("v")
    ///
    public let rawValue: Character
    
    /// The type of this character.
    ///
    ///     let character = THCharacter("t", type: .correct)
    ///     character.type // .correct
    ///
    public var type: CharacterType
    
    
    /// A boolean value that indicates whether the letter case of this character is correct.
    ///
    /// - Note: `Nil` value means that the letter case does not matter.
    /// This is when the text is leaded to a certain version, for example, to its lowercase version.
    public var hasCorrectLetterCase: Bool?
    
    /// A boolean value that indicates whether the type of this character is correct.
    public var isCorrect: Bool { type == .correct }
    
    /// A boolean value that indicates whether the type of this character is missing.
    public var isMissing: Bool { type == .missing }
    
    /// A boolean value that indicates whether the type of this character is extra.
    public var isExtra: Bool { type == .extra }
    
    /// A boolean value that indicates whether the type of this character is swapped.
    public var isSwapped: Bool {
        if case .swapped = type { return true }
        return false
    }
    
    /// A boolean value that indicates whether the type of this character is misspell.
    public var isMisspell: Bool {
        if case .misspell = type { return true }
        return false
    }
    
    
    /// An uppercase version of this character.
    ///
    ///     let character = THCharacter("a", type: .misspell("b"))
    ///     character.uppercased // THCharacter("A", type: .misspell("B"))
    ///
    /// - Note: The uppercase character has no boolean indicator of its letter case correctness.
    public var uppercased: THCharacter {
        let newRawValue = rawValue.uppercased().toCharacter!
        let newType: CharacterType
        switch self.type {
        case .misspell(let correctChar):
            let newCorrectChar = correctChar.uppercased().toCharacter!
            newType = CharacterType.misspell(newCorrectChar)
        default:
            newType = type
        }
        return THCharacter(newRawValue, type: newType, hasCorrectLetterCase: nil)
    }
    
    /// A lowercase version of this character.
    ///
    ///     let character = THCharacter("A", type: .misspell("B"))
    ///     character.lowercased // THCharacter("a", type: .misspell("b"))
    ///
    /// - Note: The lowercase character has no boolean indicator of its letter case correctness.
    public var lowercased: THCharacter {
        let newRawValue = rawValue.lowercased().toCharacter!
        let newType: CharacterType
        switch self.type {
        case .misspell(let correctChar):
            let newCorrectChar = correctChar.lowercased().toCharacter!
            newType = CharacterType.misspell(newCorrectChar)
        default:
            newType = type
        }
        return THCharacter(newRawValue, type: newType, hasCorrectLetterCase: nil)
    }
    
    
    // MARK: - Init
    
    /// Creates a character instance.
    public init(_ rawValue: Character, type: CharacterType, hasCorrectLetterCase: Bool? = nil) {
        self.rawValue = rawValue
        self.type = type
        self.hasCorrectLetterCase = hasCorrectLetterCase
    }
    
}


extension THCharacter: CustomStringConvertible {
    
    /// The textual representation of this character.
    ///
    ///     let char = THCharacter("s", type: .missing)
    ///     print(char)
    ///     // Prints "Character 's' of type: missing"
    ///
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


extension THCharacter {
    
    /// A type that describes a character relative to the original one.
    ///
    /// There are only five types of character: `correct`, `missing`, `swapped`, `misspell` and `extra`.
    public enum CharacterType: Equatable {
        
        /// A type that indicates whether a character is correct.
        /// This means that this character is the same as the original one.
        case correct
        
        /// A type that indicates whether a character is swapped with another one.
        /// This means that if these two characters are swapped back, they will become correct.
        case swapped(position: SwappedPosition)
        
        /// A type that indicates whether a character is missing.
        /// This means that this character is in the original text but is missing in the entered one.
        case missing
        
        /// A type that indicates whether a character is extra.
        case extra
        
        /// A type that indicates whether a character is misspell, and has associated value that is a correct character.
        case misspell(_ correctChar: Character)
        
        /// Creates a character type instance with the `.extra` value.
        public init() { self = .extra }
        
    }
    
}


extension THCharacter.CharacterType {
    
    /// A type that specifies a character position relative to the correct one.
    ///
    /// This is used when two characters are correct but swapped.
    public enum SwappedPosition {
        
        /// A position of a character that is to the left of the correct position.
        case left
        
        /// A position of a character that is to the right of the correct position.
        case right
    }
    
}


extension THCharacter {
    
    public static func == (lhs: THCharacter, rhs: THCharacter) -> Bool {
        if lhs.rawValue == rhs.rawValue, lhs.type == rhs.type, lhs.hasCorrectLetterCase == rhs.hasCorrectLetterCase {
            return true
        } else {
            return false
        }
    }
    
}
