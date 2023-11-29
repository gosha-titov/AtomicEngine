// Implementation notes
// ====================
//
//  (source texts) –> (math basis) –> (formed text) -> [edited text] -> (displayed text)
//                                                      –––––––––––
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
//     Initial values           After forming         After adjusting        After editing
// +––––––––––––––+–––––+    +–––––––+–––––––––+    +–––––––+–––––––––+    +–––––––+–––––––+
// | accurateText | day |    | text  | d a y y |    | text  | d a y y |    | text  | d y y |
// +--------------+-----+ –> +-------+---------+ –> +-------+---------+ –> +-------+-------+
// | comparedText | dyy |    | types | + ? + ! |    | types | + ? ! + |    | types | + a + |
// +––––––––––––––+–––––+    +–––––––+–––––––––+    +–––––––+–––––––––+    +–––––––+–––––––+
//
//
// Step 1: adding misspell chars
//
//     Initial values           After forming         After editing
// +––––––––––––––+–––––+    +–––––––+–––––––––+    +–––––––+–––––––+
// | accurateText | day |    | text  | d a e y |    | text  | d e y |
// +--------------+-----+ –> +-------+---------+ –> +-------+-------+
// | comparedText | dey |    | types | + ? ! + |    | types | + a + |
// +––––––––––––––+–––––+    +–––––––+–––––––––+    +–––––––+–––––––+
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
internal final class LMTextEditor {
    
    // MARK: - Make Text User Friendly
    
    /// Edits the given text by making it user-friendly.
    ///
    ///     let accurateText = "Hello"
    ///     let comparedText = "Halol"
    ///     let configuration = LMConfiguration()
    ///
    ///     let formedText = LMTextFormer.formText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: configuration
    ///     )
    ///     /*[LMCharacter("H", type: .correct),
    ///        LMCharacter("e", type: .missing),
    ///        LMCharacter("a", type: .extra  ),
    ///        LMCharacter("l", type: .correct),
    ///        LMCharacter("o", type: .extra  ),
    ///        LMCharacter("l", type: .correct),
    ///        LMCharacter("o", type: .missing)]*/
    ///
    ///     let editedText = LMTextEditor.makeTextUserFriendly(
    ///         formedText,
    ///         with: configuration
    ///     )
    ///     /*[LMCharacter("H", type: .correct),
    ///        LMCharacter("a", type: .misspell("o")),
    ///        LMCharacter("l", type: .correct),
    ///        LMCharacter("o", type: .swapped(position: .left ),
    ///        LMCharacter("l", type: .swapped(position: .right) )]*/
    ///
    /// - Returns: The edited text that is user-friendly and is ready to be displayed.
    @inlinable
    internal static func makeTextUserFriendly(_ text: LMText, with configuration: LMConfiguration) -> LMText {
        var text = adjusting(text)
        text = addindMisspellChars(to: text)
        text = addingSwappedChars(to: text)
        return text
    }
    
    
    // MARK: - Adding Misspell Chars
    
    /// Returns a text with added misspell chars.
    ///
    /// This method finds `.missing` and `.extra` chars near to each other and replaces them to a misspell one.
    ///
    ///     let accurateText = "day"
    ///     let comparedText = "dey"
    ///
    ///     let formedText = LMTextFormer.formText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: THConfiguration()
    ///     )
    ///     /*[LMCharacter("d", type: .correct),
    ///        LMCharacter("a", type: .missing),
    ///        LMCharacter("e", type: .extra  ),
    ///        LMCharacter("y", type: .correct)]*/
    ///
    ///     let editedText = addindMisspellChars(to: formedText, with)
    ///     /*[LMCharacter("d", type: .correct       ),
    ///        LMCharacter("e", type: .misspell("a") ),
    ///        LMCharacter("y", type: .correct       )]*/
    ///
    /// - Returns: An edited text that has misspell chars.
    @inlinable @inline(__always)
    internal static func addindMisspellChars(to text: LMText) -> LMText {
        
        var indexesOfMissingChars = [Int]()
        var indexesOfExtraChars   = [Int]()
        var text = text
        var offset = Int()
        
        for i in 0..<text.count {
            var index: Int { i + offset }
            switch text[index].type {
             case .missing:
                 if indexesOfExtraChars.count > 0 {
                     let indexOfExtraChar = indexesOfExtraChars.removeFirst()
                     let extraChar = text[indexOfExtraChar].rawValue
                     let missingChar = text[index].rawValue
                     let misspellChar = LMCharacter(extraChar, type: .misspell(missingChar))
                     text[indexOfExtraChar] = misspellChar
                     text.remove(at: index)
                     offset -= 1
                 } else {
                     indexesOfMissingChars.append(index)
                 }
             case .extra:
                 if indexesOfMissingChars.count > 0 {
                     let indexOfMissingChar = indexesOfMissingChars.removeFirst()
                     let missingChar = text[indexOfMissingChar].rawValue
                     let extraChar = text[index].rawValue
                     let misspellChar = LMCharacter(extraChar, type: .misspell(missingChar))
                     text[indexOfMissingChar] = misspellChar
                     text.remove(at: index)
                     offset -= 1
                 } else {
                     indexesOfExtraChars.append(index)
                 }
             default:
                 indexesOfMissingChars = []
                 indexesOfExtraChars = []
             }
        }
        
        return text
    }
    
    
    // MARK: - Adding Swapped Chars
    
    /// Returns a text with added swapped chars.
    ///
    /// This method finds `.extra` and `.missing` equal chars through the `.correct` char and replaces them to swapped ones.
    ///
    ///     let accurateText = "day"
    ///     let comparedText = "dya"
    ///
    ///     let formedText = LMTextFormer.formText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: THConfiguration()
    ///     )
    ///     /*[LMCharacter("d", type: .correct),
    ///        LMCharacter("y", type: .extra  ),
    ///        LMCharacter("a", type: .correct),
    ///        LMCharacter("y", type: .missing)]*/
    ///
    ///     let editedText = addindSwappedChars(to: formedText)
    ///     /*[LMCharacter("d", type: .correct),
    ///        LMCharacter("y", type: .swapped(position: .left),
    ///        LMCharacter("a", type: .swapped(position: .right) )]*/
    ///
    /// - Returns: An edited text that has swapped chars.
    @inlinable @inline(__always)
    internal static func addingSwappedChars(to text: LMText) -> LMText {
        
        var text = text
        
        // range should be reversed or we should have offset index
        for index in (1..<text.count - 1).reversed() {
            
            let prevChar = text[index - 1], nextChar = text[index + 1]
            let prevAndNextCharsAreEqual = prevChar.rawValue.lowercased() == nextChar.rawValue.lowercased()
            let currentCharIsCorrect = text[index].isCorrect
            
            if prevAndNextCharsAreEqual, prevChar.isExtra, currentCharIsCorrect, nextChar.isMissing {
                text[index - 1].type = .swapped(position: .left)
                text[index]    .type = .swapped(position: .right)
                text.remove(at: index + 1)
            }
        }
        
        return text
    }
    
    
    // MARK: - Adjusting Text
    
    /// Returns an adjusted text in which certain characters can be "rearranged".
    /// This method prepares the given text so that the next methods can find all mistakes.
    ///
    ///     let accurateText = "day"
    ///     let comparedText = "dyy"
    ///
    ///     let formedText = LMTextFormer.formText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: configuration
    ///     )
    ///     /*[LMCharacter("d", type: .correct),
    ///        LMCharacter("a", type: .missing),
    ///        LMCharacter("y", type: .correct),
    ///        LMCharacter("y", type: .extra  )]*/
    ///
    ///     let adjustedText = adjusting(formedText)
    ///     /*[LMCharacter("d", type: .correct),
    ///        LMCharacter("a", type: .missing),
    ///        LMCharacter("y", type: .extra  ),
    ///        LMCharacter("y", type: .correct)]*/
    ///
    @inlinable @inline(__always)
    internal static func adjusting(_ formedText: LMText) -> LMText {
        
        var countOfEqualCorrectChars = Int()
        var countOfMissingChars = Int()
        var indexOfFirstCorrectChar: Int? = nil
        var formedText = formedText
        
        func resetValues() -> Void {
            indexOfFirstCorrectChar = nil
            countOfEqualCorrectChars = 0
            countOfMissingChars = 0
        }
        
        for (currentIndex, currentChar) in formedText.enumerated() {
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
                    let firstCorrectChar = formedText[indexOfFirstCorrectChar]
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
                      formedText[indexOfFirstChar].rawValue.lowercased() == currentChar.rawValue.lowercased()
                else {
                    resetValues()
                    continue
                }
                let indexOfLastChar = indexOfFirstChar + countOfEqualCorrectChars - 1
                for index in ((indexOfFirstChar + 1)...(indexOfLastChar + 1)).reversed() {
                    let previousChar = formedText[index - 1]
                    if let previousLetterCase = previousChar.hasCorrectLetterCase {
                        let currentChar = formedText[index]
                        if currentChar.rawValue == previousChar.rawValue {
                            formedText[index].hasCorrectLetterCase = previousLetterCase
                        } else {
                            formedText[index].hasCorrectLetterCase = !previousLetterCase
                        }
                    } else {
                        formedText[index].hasCorrectLetterCase = nil
                    }
                    formedText[index].type = .correct
                }
                formedText[indexOfFirstChar].hasCorrectLetterCase = nil
                formedText[indexOfFirstChar].type = .extra
                indexOfFirstCorrectChar! += 1
                countOfMissingChars -= 1
            default: resetValues()
            }
        }
        
        return formedText
    }
    
    
    // MARK: - Init
    
    /// Creates a text editor instance.
    private init() {}
    
}
