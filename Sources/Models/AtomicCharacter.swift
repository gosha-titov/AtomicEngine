public struct AtomicCharacter: Equatable {
    
    public let rawValue: Character
    public let type: AtomicType
    public let hasCorrectLetterCase: Bool
    
    public init(rawValue: Character, type: AtomicType, hasCorrectLetterCase: Bool) {
        self.rawValue = rawValue
        self.type = type
        self.hasCorrectLetterCase = hasCorrectLetterCase
    }
    
}


extension AtomicCharacter {
    
    public enum AtomicType: Equatable {
        case correct, swapped, missing, extra
        case misspell(_ correctChar: Character)
        
        public init() { self = .extra }
    }
    
}


extension AtomicCharacter {
    
    public static func == (lhs: AtomicCharacter, rhs: AtomicCharacter) -> Bool {
        if lhs.rawValue == rhs.rawValue, lhs.type == rhs.type, lhs.hasCorrectLetterCase == rhs.hasCorrectLetterCase {
            return true
        } else {
            return false
        }
    }
    
}
