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


internal extension THText {
    
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
    func leading(to version: THConfiguration.LetterCaseVersion) -> THText {
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
    mutating func lead(to version: THConfiguration.LetterCaseVersion) -> Void {
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
    init(from string: String, type: THCharacter.CharacterType) {
        let atomicText = string.map { THCharacter($0, type: type) }
        self.init(atomicText)
    }
    
}
