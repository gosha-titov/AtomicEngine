// Implementation notes
// ====================
//
// +––––––––––––––––+
// | Types denoting |
// +----------------+
// | "+" – correct  |
// | "?" - missing  |
// | "^" – swapped  |
// | "m" – misspell |
// | "!" – extra    |
// +––––––––––––––––+
//
//
// Step 0: adjusting source atomic text
//
//     Initial values                 After forming                         After adjusting                        After editing
// +––––––––––––––+–––––+       +–––––––––––––+–––––––––+              +–––––––––––––+–––––––––+              +–––––––––––––+–––––––+
// | accurateText | day |       | atomicText  | d a y y |              | atomicText  | d a y y |              | atomicText  | d y y |
// +--------------+-----+ ––––> +-------------+---------+ –––––––––––> +-------------+---------+ –––––––––––> +-------------+-------+
// | comparedText | dyy |       | atomicTypes | + ? + ! |              | atomicTypes | + ? ! + |              | atomicTypes | + a + |
// +––––––––––––––+–––––+       +–––––––––––––+–––––––––+              +–––––––––––––+–––––––––+              +–––––––––––––+–––––––+
// +––––––––––––––+––––––––+    +–––––––––––––+–––––––––––––––––––+    +–––––––––––––+–––––––––––––––––––+    +–––––––––––––+–––––––––––––+
// | accurateText | abyyyc |    | atomicText  | a b y y y y y y c |    | atomicText  | a b y y y y y y c |    | atomicText  | y y y y y y |
// +--------------+--------+ –> +-------------+-------------------+ –> +-------------+-------------------+ -> +-------------+-------------+
// | comparedText | yyyyyy |    | atomicTypes | ? ? + + + ! ! ! ? |    | atomicTypes | ? ? ! ! + + + ! ? |    | atomicTypes | a b + + + c |
// +––––––––––––––+––––––––+    +–––––––––––––+–––––––––––––––––––+    +–––––––––––––+–––––––––––––––––––+    +–––––––––––––+–––––––––––––+
//
//
// Step 1: adding misspell chars
//
//     Initial values              After forming                 After editing
// +––––––––––––––+–––––+    +–––––––––––––+–––––––––+      +–––––––––––––+–––––––+
// | accurateText | day |    | atomicText  | d a e y |      | atomicText  | d e y |
// +--------------+-----+ –> +-------------+---------+ –––> +-------------+-------+
// | comparedText | dey |    | atomicTypes | + ? ! + |      | atomicTypes | + a + |
// +––––––––––––––+–––––+    +–––––––––––––+–––––––––+      +–––––––––––––+–––––––+
// +––––––––––––––+–––––+    +–––––––––––––+–––––––––––+    +–––––––––––––+–––––––+
// | accurateText | aa  |    | atomicText  | a a b b b |    | atomicText  | b b b |
// +--------------+-----+ –> +-------------+-----------+ –> +-------------+-------+
// | comparedText | bbb |    | atomicTypes | ? ? ! ! ! |    | atomicTypes | a a ! |
// +––––––––––––––+–––––+    +–––––––––––––+–––––––––––+    +–––––––––––––+–––––––+
//
//
// Step 2: adding swapped chars
//
//     Initial values              After forming               After editing
// +––––––––––––––+–––––+    +–––––––––––––+–––––––––+    +–––––––––––––+–––––––+
// | accurateText | day |    | atomicText  | d y a y |    | atomicText  | d y a |
// +--------------+-----+ –> +-------------+---------+ –> +-------------+-------+
// | comparedText | dya |    | atomicTypes | + ! + ? |    | atomicTypes | + ^ ^ |
// +––––––––––––––+–––––+    +–––––––––––––+–––––––––+    +–––––––––––––+–––––––+
//

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
    @inlinable
    internal static func addingSwappedChars(to atomicText: AtomicText) -> AtomicText {
        
        var atomicText = atomicText
        
        // range should be reversed or we should have offset index
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
    
    
    // MARK: - Adjusting Atomic Text
    
    /// Returns an adjusted atomic text in which certain atomic characters can be "rearranged".
    /// This method prepares the given atomic text so that the next methods can find all mistakes.
    ///
    ///     let accurateText = "day"
    ///     let comparedText = "dyy"
    ///
    ///     let formedAtomicText = TextFormer.formAtomicText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: AtomicConfiguration()
    ///     )
    ///     /*[AtomicCharacter("d", type: .correct),
    ///        AtomicCharacter("a", type: .missing),
    ///        AtomicCharacter("y", type: .correct),
    ///        AtomicCharacter("y", type: .extra  )]*/
    ///
    ///     let adjustedAtomicText = adjusting(formedAtomicText)
    ///     /*[AtomicCharacter("d", type: .correct),
    ///        AtomicCharacter("a", type: .missing),
    ///        AtomicCharacter("y", type: .extra  ),
    ///        AtomicCharacter("y", type: .correct)]*/
    ///
    @inlinable
    internal static func adjusting(_ atomicText: AtomicText) -> AtomicText {
        
        var countOfEqualCorrectChars = Int()
        var countOfMissingChars = Int()
        var indexOfFirstCorrectChar: Int? = nil
        var atomicText = atomicText
        
        func resetValues() -> Void {
            indexOfFirstCorrectChar = nil
            countOfEqualCorrectChars = 0
            countOfMissingChars = 0
        }
        
        for (currentIndex, currentChar) in atomicText.enumerated() {
            switch currentChar.type {
            case .missing:
                countOfMissingChars += 1
                indexOfFirstCorrectChar = nil
                countOfEqualCorrectChars = 0
            case .correct:
                guard countOfMissingChars > 0 else {
                    indexOfFirstCorrectChar = nil
                    countOfEqualCorrectChars = 0
                    continue
                }
                if let indexOfFirstCorrectChar {
                    let firstCorrectChar = atomicText[indexOfFirstCorrectChar]
                    guard firstCorrectChar.rawValue.lowercased() == currentChar.rawValue.lowercased() else {
                        resetValues()
                        continue
                    }
                } else {
                    indexOfFirstCorrectChar = currentIndex
                }
                countOfEqualCorrectChars += 1
            case .extra:
                guard countOfMissingChars > 0, let indexOfFirstChar = indexOfFirstCorrectChar,
                      atomicText[indexOfFirstChar].rawValue.lowercased() == currentChar.rawValue.lowercased()
                else {
                    resetValues()
                    continue
                }
                let indexOfLastChar = indexOfFirstChar + countOfEqualCorrectChars - 1
                print("\(currentIndex): \(countOfMissingChars) \(indexOfFirstChar) \(indexOfLastChar)")
                for index in ((indexOfFirstChar + 1)...(indexOfLastChar + 1)).reversed() {
                    let previousChar = atomicText[index - 1]
                    if let previousLetterCase = previousChar.hasCorrectLetterCase {
                        let currentChar = atomicText[index]
                        if currentChar.rawValue == previousChar.rawValue {
                            atomicText[index].hasCorrectLetterCase = previousLetterCase
                        } else {
                            atomicText[index].hasCorrectLetterCase = !previousLetterCase
                        }
                    } else {
                        atomicText[index].hasCorrectLetterCase = nil
                    }
                    atomicText[index].type = .correct
                }
                atomicText[indexOfFirstChar].hasCorrectLetterCase = nil
                atomicText[indexOfFirstChar].type = .extra
                indexOfFirstCorrectChar! += 1
                countOfMissingChars -= 1
            default: resetValues()
            }
        }
        
        return atomicText
    }
    
    
    // MARK: - Init
    
    /// Creates a text editor instance.
    private init() {}
    
}
