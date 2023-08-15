public typealias AtomicText = [AtomicCharacter]


internal extension AtomicText {
    
    /// Returns an atomic text leaded to the given letter case version.
    ///
    ///     let atomicText = AtomicText(
    ///         from: "hELlo",
    ///         withType: .correct
    ///     ).leading(to: .lowercase)
    ///
    ///     /*[AtomicCharacter("h", type: .correct),
    ///        AtomicCharacter("e", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("o", type: .correct)]*/
    ///
    func leading(to version: AtomicConfiguration.LetterCaseVersion) -> AtomicText {
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
    
    /// Leads this atomic text to the given letter case version.
    ///
    ///     var atomicText = AtomicText(from: "hELlo", withType: .correct)
    ///     atomicText.lead(to: .lowercase)
    ///
    ///     /*[AtomicCharacter("h", type: .correct),
    ///        AtomicCharacter("e", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("o", type: .correct)]*/
    ///
    mutating func lead(to version: AtomicConfiguration.LetterCaseVersion) -> Void {
        self = leading(to: version)
    }
    
    /// Creates an atomic text instance converted from the given string where all atomic characters are one-type.
    ///
    ///     let atomicText = AtomicText(from: "Hello", type: .correct)
    ///
    ///     /*[AtomicCharacter("H", type: .correct),
    ///        AtomicCharacter("e", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("o", type: .correct)]*/
    ///
    init(from text: String, type: AtomicCharacter.AtomicType) {
        let atomicText = text.map { AtomicCharacter($0, type: type) }
        self.init(atomicText)
    }
    
}
