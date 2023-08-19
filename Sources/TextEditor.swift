/// A text editor that consists of methods to make a formed atomic text user-friendly.
internal final class TextEditor {
    
    // MARK: - Adding Misspell Chars
    
    /// Returns an atomic text with added misspell chars.
    ///
    /// This method finds `.missing` and `.extra` chars near to each other and replaces them to a misspell char.
    ///
    ///     let accurateText = "day"
    ///     let comparedText = "dey"
    ///
    ///     let formedAtomicText = TextFormer.formAtomicText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: AtomicConfiguration()
    ///     )
    ///     /*[AtomicCharacter("d", type: .correct),
    ///        AtomicCharacter("a", type: .missing),
    ///        AtomicCharacter("e", type: .extra  ),
    ///        AtomicCharacter("y", type: .correct)]*/
    ///
    ///     let atomicText = addindMisspellChars(to: atomicText)
    ///     /*[AtomicCharacter("d", type: .correct       ),
    ///        AtomicCharacter("e", type: .misspell("a") ),
    ///        AtomicCharacter("y", type: .correct       )]*/
    ///
    /// - Returns: An atomic text that has misspell chars.
    @inlinable
    internal static func addindMisspellChars(to atomicText: AtomicText) -> AtomicText {
        
        var indexesOfMissingChars = [Int]()
        var indexesOfExtraChars   = [Int]()
        var atomicText = atomicText
        var offset = Int()
        
        for i in 0..<atomicText.count {
            var index: Int { i + offset }
            switch atomicText[index].type {
             case .missing:
                 if indexesOfExtraChars.count > 0 {
                     let indexOfExtraChar = indexesOfExtraChars.removeFirst()
                     let extraChar = atomicText[indexOfExtraChar].rawValue
                     let missingChar = atomicText[index].rawValue
                     let misspellChar = AtomicCharacter(extraChar, type: .misspell(missingChar))
                     atomicText[indexOfExtraChar] = misspellChar
                     atomicText.remove(at: index)
                     offset -= 1
                 } else {
                     indexesOfMissingChars.append(index)
                 }
             case .extra:
                 if indexesOfMissingChars.count > 0 {
                     let indexOfMissingChar = indexesOfMissingChars.removeFirst()
                     let missingChar = atomicText[indexOfMissingChar].rawValue
                     let extraChar = atomicText[index].rawValue
                     let misspellChar = AtomicCharacter(extraChar, type: .misspell(missingChar))
                     atomicText[indexOfMissingChar] = misspellChar
                     atomicText.remove(at: index)
                     offset -= 1
                 } else {
                     indexesOfExtraChars.append(index)
                 }
             default:
                 indexesOfMissingChars = []
                 indexesOfExtraChars = []
             }
        }
        
        return atomicText
    }
    
    
    // MARK: - Init
    
    /// Creates a text editor instance.
    private init() {}
    
}
