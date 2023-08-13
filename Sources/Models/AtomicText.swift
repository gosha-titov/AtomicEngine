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
        return text.map { AtomicCharacter(rawValue: $0, type: type) }
    }
    
}
