public typealias AtomicText = [AtomicCharacter]


internal extension AtomicText {
    
    /// Creates an atomic text from a String value where all atomic characters are of the given type.
    ///
    ///     let atomicText = AtomicText.from("Hello", withType: .correct)
    ///     /*[AtomicCharacter("H", type: .correct),
    ///        AtomicCharacter("e", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("o", type: .correct)]*/
    ///
    static func from(_ text: String, withType type: AtomicCharacter.AtomicType) -> AtomicText {
        return text.map { AtomicCharacter($0, type: type) }
    }
    
    /// Returns an atomic text leaded to the given letter case version.
    ///
    ///     let atomicText = AtomicText.from("hELlo", withType: .correct)
    ///                                .leading(to: .lowercase)
    ///     /*[AtomicCharacter("h", type: .correct),
    ///        AtomicCharacter("e", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("o", type: .correct)]*/
    ///
    func leading(to version: AtomicConfiguration.LetterCaseAction.Version) -> AtomicText {
        var atomicText = self
        var str = atomicText.map { $0.rawValue }.toString()
        let types = atomicText.map { $0.type }
        switch version {
        case .capitalized: str.capitalize()
        case .uppercase:   str.uppercase()
        case .lowercase:   str.lowercase()
        }
        atomicText = zip(str, types).map { AtomicCharacter($0.0, type: $0.1) }
        return atomicText
    }
    
}
