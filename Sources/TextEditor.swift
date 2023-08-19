/// A text editor that consists of methods to make a formed atomic text user-friendly.
internal final class TextEditor {
    
    // MARK: - Adding Misspell Chars
    
    /// Returns an atomic text with added misspell chars.
    ///
    /// This method finds `.missing` and `.extra` chars near to each other and replaces them to a misspell one.
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
    
    
    // MARK: - Adding Swapped Chars
    
    /// Returns an atomic text with added swapped chars.
    ///
    /// This method finds `.extra` and `.missing` equal chars through the `.correct` char and replaces them to swapped ones.
    ///
    ///     let accurateText = "day"
    ///     let comparedText = "dya"
    ///
    ///     let formedAtomicText = TextFormer.formAtomicText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: AtomicConfiguration()
    ///     )
    ///     /*[AtomicCharacter("d", type: .correct),
    ///        AtomicCharacter("y", type: .extra  ),
    ///        AtomicCharacter("a", type: .correct),
    ///        AtomicCharacter("y", type: .missing)]*/
    ///
    ///     let atomicText = addindSwappedChars(to: atomicText)
    ///     /*[AtomicCharacter("d", type: .correct),
    ///        AtomicCharacter("y", type: .swapped),
    ///        AtomicCharacter("a", type: .swapped)]*/
    ///
    /// - Returns: An atomic text that has swapped chars.
    internal static func addingSwappedChars(to atomicText: AtomicText) -> AtomicText {
        
        var atomicText = atomicText
        
        for index in (1..<atomicText.count - 1).reversed() {
            
            let prevChar = atomicText[index - 1], nextChar = atomicText[index + 1]
            let prevAndNextCharsAreEqual = prevChar.rawValue.lowercased() == nextChar.rawValue.lowercased()
            let currentCharIsCorrect = atomicText[index].isCorrect
            
            if prevAndNextCharsAreEqual, prevChar.isExtra, currentCharIsCorrect, nextChar.isMissing {
                atomicText[index - 1].type = .swapped
                atomicText[index]    .type = .swapped
                atomicText.remove(at: index + 1)
            }
        }
        
        return atomicText
    }
    
    
    // MARK: - Init
    
    /// Creates a text editor instance.
    private init() {}
    
}
