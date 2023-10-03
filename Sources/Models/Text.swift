/// A text consisting of typed characters.
///
///     print(text)
///     /*[THCharacter("H", type: .correct),
///        THCharacter("e", type: .correct),
///        THCharacter("l", type: .correct),
///        THCharacter("l", type: .correct),
///        THCharacter("o", type: .missing)]*/
///
public typealias THText = [THCharacter]


extension THText {
    
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
    ///
    public var rawValue: String {
        var string = String()
        for char in self {
            string.append(char.rawValue)
        }
        return string
    }
    
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
    
    /// Returns a text leaded to the given letter case version.
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
    public func leading(to version: THConfiguration.LetterCaseVersion) -> THText {
        guard self.count > 0 else { return [] }
        var result = THText()
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
    public mutating func lead(to version: THConfiguration.LetterCaseVersion) -> Void {
        self = leading(to: version)
    }
    
    /// Creates a text instance converted from the given string where all characters are one-type.
    ///
    ///     let text = THText(from: "Hello", type: .correct)
    ///
    ///     /*[THCharacter("H", type: .correct),
    ///        THCharacter("e", type: .correct),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("o", type: .correct)]*/
    ///
    public init(from string: String, type: THCharacter.CharacterType) {
        let atomicText = string.map { THCharacter($0, type: type) }
        self.init(atomicText)
    }
    
}
