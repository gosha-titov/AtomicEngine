// Implementation notes
// ====================
//
//  (source texts) –> (math basis) –> [formed text] -> (edited text) -> (displayed text)
//                                     –––––––––––
//
// Example of forming a text
// –––––––––––––––––––––––––––––––––
//
//  accurateText = "hello"
//  comparedText = "hola"
//
//  +–––––––––––––––––+–––––––––––––––+  +––––––––––––––––+
//  | accurateText    | h e   l l o   |  | Types denoting |
//  | comparedText    | h   o l     a |  +----------------+
//  +-----------------+---------------+  | "+" – correct  |
//  | sourceSequence  | 0 1   2 3 4   |  | "?" - missing  |
//  | sequence        | 0   4 2    nil|  | "!" – extra    |
//  | subsequence     | 0     2       |  +––––––––––––––––+
//  | missingElements |   1     3 4   |
//  +-----------------+---------------+
//  | formedText      | h e o l l o a |
//  +-----------------+---------------+
//  | formedTypes     | + ? ! + ? ? ! |
//  +–––––––––––––––––+–––––––––––––––+
//
//
// Other notes
// –––––––––––
//
//  Only three types of chars are used for forming: `.correct`, `.missing` and `.extra`.
//  That is, the text needs to be edited by adding `.misspell` and `.swapped` chars.
//

/// A text former that consists of methods to form the basic text.
internal final class LMTextFormer {
    
    // MARK: - Form Text
    
    /// Forms a text from the given compared and accurate texts with a specific configuration.
    ///
    ///     let accurateText = "Hello"
    ///     let comparedText = "hola"
    ///
    ///     let configuration = LMConfiguration()
    ///     configuration.letterCaseAction = .make(.capitalized)
    ///
    ///     let text = LMTextFormer.formText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: configuration
    ///     )
    ///
    ///     /*[LMCharacter("H", type: .correct),
    ///        LMCharacter("e", type: .missing),
    ///        LMCharacter("o", type: .extra  ),
    ///        LMCharacter("l", type: .correct),
    ///        LMCharacter("l", type: .missing),
    ///        LMCharacter("o", type: .missing),
    ///        LMCharacter("a", type: .extra  )]*/
    ///
    /// The formation is performed if there is at least one correct char; otherwise, it returns extra or missing text.
    ///
    ///     let accurateText = "bye"
    ///     let comparedText = "hi!"
    ///
    ///     let text = LMTextFormer.formText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: LMConfiguration()
    ///     )
    ///
    ///     /*[LMCharacter("h", type: .extra),
    ///        LMCharacter("i", type: .extra),
    ///        LMCharacter("!", type: .extra)]*/
    ///
    /// - Returns: A text by combining compared and accurate texts.
    @inlinable
    internal static func formText(from comparedText: String, relyingOn accurateText: String, with configuration: LMConfiguration) -> LMText {
        
        var missingAccurateText: LMText { plainText(from: accurateText, ofType: .missing, with: configuration) }
        var wrongComparedText:   LMText { plainText(from: comparedText, ofType: .extra,   with: configuration) }
        
        guard !comparedText.isEmpty else { return missingAccurateText }
        guard !accurateText.isEmpty else { return wrongComparedText   }
        
        let quickComplianceIsPassed = checkQuickCompliance(for: comparedText, relyingOn: accurateText, to: configuration)
        guard quickComplianceIsPassed else { return wrongComparedText }
        
        let basis = LMMathCore.calculateBasis(for: comparedText, relyingOn: accurateText)
        
        let exactComplianceIsPassed = checkExactCompliance(for: basis, to: configuration)
        guard exactComplianceIsPassed else { return wrongComparedText }
        
        var formedText = wrongComparedText
        
        formedText = addingCorrectChars(to: formedText, relyingOn: accurateText, basedOn: basis, conformingTo: configuration)
        formedText = addingMissingChars(to: formedText, relyingOn: accurateText, basedOn: basis, conformingTo: configuration)
        
        formedText = applying(configuration, to: formedText)
        
        return formedText
    }
    
    
    // MARK: - Adding Missing Chars
    
    /// Returns a text with added missing chars.
    ///
    /// This method inserts missing chars after correct ones are set.
    /// The existing chars are not changed, but missing are added.
    /// That is, the count of typified chars is changed, **which makes the basis no longer usable**.
    ///
    /// - Note: The order of typified chars should not changed before this method is called.
    /// - Returns: A text that has missing chars.
    @inlinable
    internal static func addingMissingChars(to text: LMText, relyingOn accurateText: String, basedOn basis: LMMathCore.Basis, conformingTo configuration: LMConfiguration) -> LMText {
        
        var text = text, subindex = Int()
        var subelement: Int { basis.subsequence[subindex] }
        var missingElements = basis.missingElements
        var indexToInsert = Int(), offset = Int()
        
        for (index, element) in basis.sequence.enumerated() where element == subelement {
            
            func insert(_ indexes: [Int]) -> Void {
                for index in indexes.reversed() {
                    let rawCharacter = accurateText[index]
                    let character = LMCharacter(rawCharacter, type: .missing)
                    text.insert(character, at: indexToInsert)
                }
            }
            
            let insertions = missingElements.filter { $0 < subelement }
            missingElements.removeFirst(insertions.count)
            insert(insertions)
            
            offset += insertions.count
            indexToInsert = (index + 1) + offset
            subindex += 1
            
            guard subindex < basis.subsequence.count else {
                insert(missingElements); break
            }
        }
        
        return text
    }
    
    
    // MARK: - Adding Correct Chars
    
    /// Returns a text with added correct chars.
    ///
    /// This method looks for the elements of `basis.subsequence` in `basis.sequence`, when this happens this char becomes correct.
    ///
    /// Аfter executing this method, the values and the count of typified chars and are not changed, there are no rearrangements of typed chars.
    /// Only some types of existing chars are changed from `.extra` to `.correct`.
    ///
    /// - Note: The order of typified chars should not be changed before this method is called.
    /// - Returns: A text that has correct chars.
    @inlinable
    internal static func addingCorrectChars(to text: LMText, relyingOn accurateText: String, basedOn basis: LMMathCore.Basis, conformingTo configuration: LMConfiguration) -> LMText {
        
        var text = text, subindex = Int()
        var subelement: Int { basis.subsequence[subindex] }
        
        let shouldCompareLetterCases: Bool
        if case .compare = configuration.letterCaseAction {
            shouldCompareLetterCases = true
        } else {
            shouldCompareLetterCases = false
        }
        
        for (index, element) in basis.sequence.enumerated() where element == subelement {
            if shouldCompareLetterCases {
                let accurateChar = accurateText[subelement]
                let comparedChar = text[index].rawValue // because initially, all these chars match chars of the compared text
                text[index].hasCorrectLetterCase = accurateChar == comparedChar
            }
            text[index].type = .correct
            subindex += 1
            guard subindex < basis.subsequence.count else { break }
        }
        
        return text
    }
    
    
    // MARK: - Check Exact Compliance
    
    /// Checks for exact compliance to the given configuration.
    ///
    /// In contrast to the quick compliance, in order to check for the exact compliance this method needs a math basis.
    /// This means the checking happens only after complex calculations, but the compliance is accurate.
    ///
    /// - Note: This method checks for the presence or absence of chars and for their order.
    /// - Returns: `True` if the basis satisfies all the conditions; otherwise, `false`.
    @inlinable
    internal static func checkExactCompliance(for basis: LMMathCore.Basis, to configuration: LMConfiguration) -> Bool {
        
        guard !basis.subsequence.isEmpty else { return false }
        
        let accurateLength = basis.sourceSequence.count
        
        if let requiredCount = configuration.requiredQuantityOfCorrectChars?.count(for: accurateLength, clamped: true) {
            let countOfMatchingChars = basis.subsequence.count
            guard requiredCount <= countOfMatchingChars else { return false }
        }
        
        if let acceptableCount = configuration.acceptableQuantityOfWrongChars?.count(for: accurateLength) {
            let countOfMissingChars = basis.missingElements.count
            let countOfWrongChars = basis.sequence.count - basis.subsequence.count + basis.missingElements.count
            let maxCount = max(countOfWrongChars, countOfMissingChars) // because wrong and missing chars may be combined into misspell ones
            guard maxCount <= acceptableCount else { return false }
        }
        
        return true
    }
    
    
    // MARK: - Check Quick Compliance
    
    /// Checks for quick compliance to the given configuration.
    ///
    /// This method finds max possible compliance, this means the compliance will be inaccurate for the better.
    /// It allows you to find out in advance whether you need to do any complex calculations.
    ///
    /// For instance, the quick compliance is 70% when in fact the exact compliance is 50%.
    /// But it cannot be that the quick compliance is 50% and the exact compliance is 70%.
    /// That is, the accuaracy of the quick check is always higher or equal to the exact check.
    ///
    /// - Note: This method only checks for the presence or absence of chars, but not for their order.
    /// - Returns: `True` if the compared text possibly satisfies all the conditions; otherwise, `false`.
    @inlinable
    internal static func checkQuickCompliance(for comparedText: String, relyingOn accurateText: String, to configuration: LMConfiguration) -> Bool {
        
        let countOfCommonChars = LMMathCore.countCommonChars(between: comparedText, and: accurateText)
        
        guard countOfCommonChars > 0 else { return false }
        
        let accurateLength = accurateText.count
        
        if let requiredCount = configuration.requiredQuantityOfCorrectChars?.count(for: accurateLength, clamped: true) {
            guard requiredCount <= countOfCommonChars else { return false }
        }
        
        if let acceptableCount = configuration.acceptableQuantityOfWrongChars?.count(for: accurateLength) {
            let countOfMissingChars = accurateText.count - countOfCommonChars
            let countOfWrongChars = comparedText.count - countOfCommonChars
            let maxCount = max(countOfWrongChars, countOfMissingChars) // because wrong and missing chars may be combined into misspell ones
            guard maxCount <= acceptableCount else { return false }
        }
        
        return true
    }
    
    
    // MARK: - Plain Text
    
    /// Makes a text from the given string where all atomic are one-type, and apply a specific configuration to it.
    ///
    ///     var configuration = THConfiguration()
    ///     configuration.letterCaseAction = .make(.capitalized)
    ///
    ///     let text = plainText(
    ///         from: "hello",
    ///         ofType: .correct,
    ///         with: configuration
    ///     )
    ///
    ///     /*[THCharacter("H", type: .correct),
    ///        THCharacter("e", type: .correct),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("o", type: .correct)]*/
    ///
    /// - Returns: A created text instance with the applied configuration.
    @inlinable @inline(__always)
    internal static func plainText(from text: String, ofType type: LMCharacter.CharacterType, with configuration: LMConfiguration) -> LMText {
        let text = LMText(string: text, type: type)
        return applying(configuration, to: text)
    }
    
    
    // MARK: - Applying Configuration
    
    /// Returns a text with applied configuration.
    @inlinable @inline(__always)
    internal static func applying(_ configuration: LMConfiguration, to text: LMText) -> LMText {
        var text = text
        if case .make(let version) = configuration.letterCaseAction {
            text.lead(to: version)
        }
        return text
    }
    
    
    // MARK: - Init
    
    /// Creates a text former instance.
    private init() {}
    
}
