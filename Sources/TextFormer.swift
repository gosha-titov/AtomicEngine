// Implementation notes
// ====================
//
// Example of forming an atomic text
// –––––––––––––––––––––––––––––––––
//
//  accurateText = "hello"
//  comparedText = "hola"
//
//  (texts) –> [math basis] –> {atomic text}
//  +–––––––––––––––––+–––––––––––––––+  +––––––––––––––––+
//  | accurateText    | h e   l l o   |  | Types denoting |
//  | comparedText    | h   o l     a |  +----------------+
//  +-----------------+---------------+  | "$" – correct  |
//  | sourceSequence  | 0 1   2 3 4   |  | "?" - missing  |
//  | sequence        | 0   4 2    nil|  | "!" – extra    |
//  | subsequence     | 0     2       |  +––––––––––––––––+
//  | missingElements |   1     3 4   |
//  +-----------------+---------------+
//  | atomicText      | h e o l l o a |
//  +-----------------+---------------+
//  | atomicTypes     | $ ? ! $ ? ? ! |
//  +–––––––––––––––––+–––––––––––––––+
//
//
// Other notes
// –––––––––––
//
//  Only three types of chars are used for forming: `.correct`, `.missing` and `.extra`.
//  That is, the atomic text needs to be edited by adding `.misspell` and `.swapped` chars.
//

/// A text former that consists of methods to form the basic atomic text.
internal final class TextFormer {
    
    // MARK: - Form Atomic Text
    
    /// Forms an atomic text from the given compared and accurate texts with a specific configuration.
    ///
    ///     let accurateText = "Hello"
    ///     let comparedText = "hola"
    ///
    ///     let configuration = AtomicConfiguration()
    ///     configuration.letterCaseAction = .leadTo(.capitalized)
    ///
    ///     let atomicText = TextFormer.formAtomicText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: configuration
    ///     )
    ///
    ///     /*[AtomicCharacter("H", type: .correct),
    ///        AtomicCharacter("e", type: .missing),
    ///        AtomicCharacter("o", type: .extra  ),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("l", type: .missing),
    ///        AtomicCharacter("o", type: .missing),
    ///        AtomicCharacter("a", type: .extra  )]*/
    ///
    /// The formation is performed if there is at least one correct char; otherwise, it returns extra or missing atomic text.
    ///
    ///     let accurateText = "bye"
    ///     let comparedText = "hi!"
    ///
    ///     let atomicText = TextFormer.formAtomicText(
    ///         from: comparedText,
    ///         relyingOn: accurateText,
    ///         with: AtomicConfiguration()
    ///     )
    ///
    ///     /*[AtomicCharacter("h", type: .extra),
    ///        AtomicCharacter("i", type: .extra),
    ///        AtomicCharacter("!", type: .extra)]*/
    ///
    /// - Returns: An atomic text by merging compared and accurate texts.
    @inlinable
    internal static func formAtomicText(from comparedText: String, relyingOn accurateText: String, with configuration: AtomicConfiguration) -> AtomicText {
        
        var missingAccurateAtomicText: AtomicText { plainAtomicText(from: accurateText, ofType: .missing, with: configuration) }
        var wrongComparedAtomicText:   AtomicText { plainAtomicText(from: comparedText, ofType: .extra,   with: configuration) }
        
        guard !comparedText.isEmpty else { return missingAccurateAtomicText }
        guard !accurateText.isEmpty else { return wrongComparedAtomicText   }
        
        let quickComplianceIsPassed = checkQuickCompliance(for: comparedText, relyingOn: accurateText, to: configuration)
        guard quickComplianceIsPassed else { return wrongComparedAtomicText }
        
        let basis = MathCore.calculateBasis(for: comparedText, relyingOn: accurateText)
        
        let exactComplianceIsPassed = checkExactCompliance(for: basis, to: configuration)
        guard exactComplianceIsPassed else { return wrongComparedAtomicText }
        
        var atomicText = wrongComparedAtomicText
        
        atomicText = addingCorrectChars(to: atomicText, relyingOn: accurateText, basedOn: basis, with: configuration)
        atomicText = addingMissingChars(to: atomicText, relyingOn: accurateText, basedOn: basis)
        
        atomicText = applying(configuration, to: atomicText)
        
        return atomicText
    }
    
    
    // MARK: - Adding Missing Chars
    
    /// Returns an atomic text with added missing chars.
    ///
    /// This method inserts missing chars after correct ones are set.
    /// The existing atomic chars are not changed, but missing are added.
    /// That is, the count of typified chars is changed, **which makes the basis no longer usable**.
    ///
    /// - Note: The order of typified chars should not changed before this method is called.
    /// - Returns: An atomic text that has missing chars.
    @inlinable
    internal static func addingMissingChars(to atomicText: AtomicText, relyingOn accurateText: String, basedOn basis: MathCore.Basis) -> AtomicText {
        
        var atomicText = atomicText, subindex = Int()
        var subelement: Int { basis.subsequence[subindex] }
        var missingElements = basis.missingElements
        var indexToInsert = Int(), offset = Int()
        
        for (index, element) in basis.sequence.enumerated() where element == subelement {
            
            func insert(_ indexes: [Int]) -> Void {
                for index in indexes.reversed() {
                    let char = accurateText[index]
                    let atomicChar = AtomicCharacter(char, type: .missing)
                    atomicText.insert(atomicChar, at: indexToInsert)
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
        
        return atomicText
    }
    
    
    // MARK: - Adding Correct Chars
    
    /// Returns an atomic text with added correct chars.
    ///
    /// This method looks for the elements of `basis.subsequence` in `basis.sequence`, when this happens this char becomes correct.
    ///
    /// Аfter executing this method, the values and the count of typified chars and are not changed, there are no rearrangements of atomic chars.
    /// Only some types of existing chars are changed from `.extra` to `.correct`.
    ///
    /// - Note: The order of typified chars should not be changed before this method is called.
    /// - Returns: An atomic text that has correct chars.
    @inlinable
    internal static func addingCorrectChars(to atomicText: AtomicText, relyingOn accurateText: String, basedOn basis: MathCore.Basis, with configuration: AtomicConfiguration) -> AtomicText {
        
        var atomicText = atomicText, subindex = Int()
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
                let comparedChar = atomicText[index].rawValue // because initially, all atomic chars match chars of the compared text
                atomicText[index].hasCorrectLetterCase = accurateChar == comparedChar
            }
            atomicText[index].type = .correct
            subindex += 1
            guard subindex < basis.subsequence.count else { break }
        }
        
        return atomicText
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
    internal static func checkExactCompliance(for basis: MathCore.Basis, to configuration: AtomicConfiguration) -> Bool {
        
        guard !basis.subsequence.isEmpty else { return false }
        
        let accurateLength = basis.sourceSequence.count
        if let requiredCount = configuration.requiredQuantityOfCorrectChars?.count(for: accurateLength) {
            let countOfMatchingChars = basis.subsequence.count
            guard requiredCount <= countOfMatchingChars else { return false }
        }
        
        let comparedLength = basis.sequence.count
        if let acceptableCount = configuration.acceptableQuantityOfWrongChars?.count(for: comparedLength) {
            let countOfWrongChars = basis.sequence.count - basis.subsequence.count + basis.missingElements.count
            guard countOfWrongChars <= acceptableCount else { return false }
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
    internal static func checkQuickCompliance(for comparedText: String, relyingOn accurateText: String, to configuration: AtomicConfiguration) -> Bool {
        
        let countOfCommonChars = MathCore.countCommonChars(between: comparedText, and: accurateText)
        
        guard countOfCommonChars > 0 else { return false }
        
        if let requiredCount = configuration.requiredQuantityOfCorrectChars?.count(for: accurateText.count) {
            guard requiredCount <= countOfCommonChars else { return false }
        }
        
        if let acceptableCount = configuration.acceptableQuantityOfWrongChars?.count(for: comparedText.count) {
            let countOfWrongChars = comparedText.count - countOfCommonChars
            guard countOfWrongChars <= acceptableCount else { return false }
        }
        
        return true
    }
    
    
    // MARK: - Plain Atomic Text
    
    /// Makes an atomic text from the given string where all atomic are one-type, and this text satisfies a specific configuration.
    ///
    ///     var configuration = AtomicConfiguration()
    ///     configuration.letterCaseAction = .leadTo(.capitalized)
    ///
    ///     let atomicText = plainAtomicText(
    ///         from: "hello",
    ///         ofType: .correct,
    ///         with: configuration
    ///     )
    ///
    ///     /*[AtomicCharacter("H", type: .correct),
    ///        AtomicCharacter("e", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("l", type: .correct),
    ///        AtomicCharacter("o", type: .correct)]*/
    ///
    /// - Returns: A created atomic text instance.
    @inlinable @inline(__always)
    internal static func plainAtomicText(from text: String, ofType type: AtomicCharacter.AtomicType, with configuration: AtomicConfiguration) -> AtomicText {
        var atomicText = AtomicText(from: text, type: type)
        atomicText = applying(configuration, to: atomicText)
        return atomicText
    }
    
    
    // MARK: - Applying Configuration
    
    /// Returns an atomic text with applied configuration.
    ///
    /// Аfter executing this method, the values, the types, the order and the count of typified chars are not changed.
    /// Only parameters such as `hasCorrectLetterCase` can be changed.
    @inlinable @inline(__always)
    internal static func applying(_ configuration: AtomicConfiguration, to atomicText: AtomicText) -> AtomicText {
        var atomicText = atomicText
        if case .leadTo(let version) = configuration.letterCaseAction {
            atomicText.lead(to: version)
        }
        return atomicText
    }
    
    
    // MARK: - Init
    
    /// Creates a text former instance.
    private init() {}
    
}
