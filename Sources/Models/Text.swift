/// A text consisting of typed characters.
///
///     print(text)
///     /*[LMCharacter("H", type: .correct, hasCorrectLetterCase: false),
///        LMCharacter("e", type: .correct, hasCorrectLetterCase: true),
///        LMCharacter("l", type: .correct, hasCorrectLetterCase: true),
///        LMCharacter("l", type: .correct, hasCorrectLetterCase: true),
///        LMCharacter("o", type: .missing, hasCorrectLetterCase: nil)]*/
///
///     text.isCompletelyCorrect // false
///     text.countOfTyposAndMistakes // 1
///     text.countOfWrongLetterCases // 1
///
///     print(text.rawValue)
///     // Prints "Hello"
///
public typealias LMText = [LMCharacter]


extension LMText {
    
    /// A boolean value that indicates whether this text has no typos or mistakes.
    public var isCompletelyCorrect: Bool {
        for char in self {
            guard char.isCorrect else { return false }
            if let letterCaseIsCorrect = char.hasCorrectLetterCase {
                guard letterCaseIsCorrect else { return false }
            }
        }
        return true
    }
    
    /// Count of typos and mistakes in this text.
    ///
    /// A misspell, missing or extra char is considered as one mistake;
    /// two swapped chars are considered as one mistake.
    public var countOfTyposAndMistakes: Int {
        var count = 0
        var countOfSwappedChars = 0
        for char in self {
            switch char.type {
            case .extra, .missing, .misspell: count += 1
            case .swapped: countOfSwappedChars += 1
            default: break
            }
        }
        return count + countOfSwappedChars / 2
    }
    
    /// Count of characters that have wrong letter case.
    ///
    /// `Nil` values are not considered.
    public var countOfWrongLetterCases: Int {
        var count = 0
        for char in self {
            if let letterCaseIsCorrect = char.hasCorrectLetterCase, letterCaseIsCorrect == false {
                count += 1
            }
        }
        return count
    }
    
    /// The string that contains all characters of this text.
    ///
    ///     let text = [
    ///         THCharacter("H", type: .correct),
    ///         THCharacter("e", type: .correct),
    ///         THCharacter("l", type: .correct),
    ///         THCharacter("l", type: .correct),
    ///         THCharacter("o", type: .correct)
    ///     ]
    ///     print(text.rawValue)
    ///     // Prints "Hello"
    ///
    public var rawValue: String {
        var string = String()
        for char in self {
            string.append(char.rawValue)
            if case let .misspell(correctChar) = char.type {
                string.append(correctChar)
            }
        }
        return string
    }
    
    
    // MARK: - Methods
    
    /// Returns a text that is leaded to the given letter case version.
    ///
    ///     let text = THText(
    ///         from: "hELlo",
    ///         withType: .correct
    ///     ).leading(to: .lowercase)
    ///
    ///     /*[THCharacter("h", type: .correct),
    ///        THCharacter("e", type: .correct),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("o", type: .correct)]*/
    ///
    /// - Note: The characters of the leading text have no boolean indicator of their letter case correctness.
    public func leading(to version: LMConfiguration.LetterCaseVersion) -> LMText {
        guard self.count > 0 else { return [] }
        var result = LMText()
        switch version {
        case .uppercase: result = map { $0.uppercased }
        case .lowercase: result = map { $0.lowercased }
        case .capitalized:
            result.append(first!.uppercased)
            guard count > 1 else { return result}
            for char in self[1...] { result.append(char.lowercased) }
        }
        return result
    }
    
    /// Leads this text to the given letter case version.
    ///
    ///     var text = THText(from: "hELlo", withType: .correct)
    ///     text.lead(to: .lowercase)
    ///
    ///     /*[THCharacter("h", type: .correct),
    ///        THCharacter("e", type: .correct),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("o", type: .correct)]*/
    ///
    /// - Note: The characters of the leading text have no boolean indicator of their letter case correctness.
    public mutating func lead(to version: LMConfiguration.LetterCaseVersion) -> Void {
        self = leading(to: version)
    }
    
    
    // MARK: - Init
    
    /// Creates a text instance from the given string where all characters are one-type.
    ///
    ///     let text = THText(string: "Hello", type: .correct)
    ///
    ///     /*[THCharacter("H", type: .correct),
    ///        THCharacter("e", type: .correct),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("o", type: .correct)]*/
    ///
    public init(string: String, type: LMCharacter.CharacterType) {
        let text = string.map { LMCharacter($0, type: type) }
        self.init(text)
    }
    
}
