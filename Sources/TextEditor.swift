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
// Step 0: adjusting source text
//
//     Initial values              After forming                   After adjusting                  After editing
// +––––––––––––––+–––––+       +–––––––+–––––––––+              +–––––––+–––––––––+              +–––––––+–––––––+
// | accurateText | day |       | text  | d a y y |              | text  | d a y y |              | text  | d y y |
// +--------------+-----+ ––––> +-------+---------+ –––––––––––> +-------+---------+ –––––––––––> +-------+-------+
// | comparedText | dyy |       | types | + ? + ! |              | types | + ? ! + |              | types | + a + |
// +––––––––––––––+–––––+       +–––––––+–––––––––+              +–––––––+–––––––––+              +–––––––+–––––––+
// +––––––––––––––+––––––––+    +–––––––+–––––––––––––––––––+    +–––––––+–––––––––––––––––––+    +–––––––+–––––––––––––+
// | accurateText | abyyyc |    | text  | a b y y y y y y c |    | text  | a b y y y y y y c |    | text  | y y y y y y |
// +--------------+--------+ –> +-------+-------------------+ –> +-------+-------------------+ -> +-------+-------------+
// | comparedText | yyyyyy |    | types | ? ? + + + ! ! ! ? |    | types | ? ? ! ! + + + ! ? |    | types | a b + + + c |
// +––––––––––––––+––––––––+    +–––––––+–––––––––––––––––––+    +–––––––+–––––––––––––––––––+    +–––––––+–––––––––––––+
//
//
// Step 1: adding misspell chars
//
//     Initial values           After forming           After editing
// +––––––––––––––+–––––+    +–––––––+–––––––––+      +–––––––+–––––––+
// | accurateText | day |    | text  | d a e y |      | text  | d e y |
// +--------------+-----+ –> +-------+---------+ –––> +-------+-------+
// | comparedText | dey |    | types | + ? ! + |      | types | + a + |
// +––––––––––––––+–––––+    +–––––––+–––––––––+      +–––––––+–––––––+
// +––––––––––––––+–––––+    +–––––––+–––––––––––+    +–––––––+–––––––+
// | accurateText | aa  |    | text  | a a b b b |    | text  | b b b |
// +--------------+-----+ –> +-------+-----------+ –> +-------+-------+
// | comparedText | bbb |    | types | ? ? ! ! ! |    | types | a a ! |
// +––––––––––––––+–––––+    +–––––––+–––––––––––+    +–––––––+–––––––+
//
//
// Step 2: adding swapped chars
//
//     Initial values           After forming         After editing
// +––––––––––––––+–––––+    +–––––––+–––––––––+    +–––––––+–––––––+
// | accurateText | day |    | text  | d y a y |    | text  | d y a |
// +--------------+-----+ –> +-------+---------+ –> +-------+-------+
// | comparedText | dya |    | types | + ! + ? |    | types | + ^ ^ |
// +––––––––––––––+–––––+    +–––––––+–––––––––+    +–––––––+–––––––+
//

/// A text editor that consists of methods to make a formed text user-friendly.
internal final class TextEditor {
    
    // MARK: - Adding Misspell Chars
    
    /// Returns a text with added misspell chars.
    ///
    /// This method finds `.missing` and `.extra` chars near to each other and replaces them to a misspell one.
    ///
    ///     let accurateText = "day"
    ///     let comparedText = "dey"
    ///
    ///     let formedText = THTextFormer.formText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: THConfiguration()
    ///     )
    ///     /*[THCharacter("d", type: .correct),
    ///        THCharacter("a", type: .missing),
    ///        THCharacter("e", type: .extra  ),
    ///        THCharacter("y", type: .correct)]*/
    ///
    ///     let editedText = addindMisspellChars(to: formedText)
    ///     /*[THCharacter("d", type: .correct       ),
    ///        THCharacter("e", type: .misspell("a") ),
    ///        THCharacter("y", type: .correct       )]*/
    ///
    /// - Returns: A text that has misspell chars.
    @inlinable
    internal static func addindMisspellChars(to atomicText: THText) -> THText {
        
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
                     let misspellChar = THCharacter(extraChar, type: .misspell(missingChar))
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
                     let misspellChar = THCharacter(extraChar, type: .misspell(missingChar))
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
    ///     let formedAtomicText = THTextFormer.formText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: THConfiguration()
    ///     )
    ///     /*[THCharacter("d", type: .correct),
    ///        THCharacter("y", type: .extra  ),
    ///        THCharacter("a", type: .correct),
    ///        THCharacter("y", type: .missing)]*/
    ///
    ///     let atomicText = addindSwappedChars(to: atomicText)
    ///     /*[THCharacter("d", type: .correct),
    ///        THCharacter("y", type: .swapped),
    ///        THCharacter("a", type: .swapped)]*/
    ///
    /// - Returns: An atomic text that has swapped chars.
    @inlinable
    internal static func addingSwappedChars(to atomicText: THText) -> THText {
        
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
    ///     let formedAtomicText = THTextFormer.formText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: THConfiguration()
    ///     )
    ///     /*[THCharacter("d", type: .correct),
    ///        THCharacter("a", type: .missing),
    ///        THCharacter("y", type: .correct),
    ///        THCharacter("y", type: .extra  )]*/
    ///
    ///     let adjustedAtomicText = adjusting(formedAtomicText)
    ///     /*[THCharacter("d", type: .correct),
    ///        THCharacter("a", type: .missing),
    ///        THCharacter("y", type: .extra  ),
    ///        THCharacter("y", type: .correct)]*/
    ///
    @inlinable
    internal static func adjusting(_ atomicText: THText) -> THText {
        
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
