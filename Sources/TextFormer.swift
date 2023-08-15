internal final class TextFormer {
    
    // MARK: - Check Exact Compliance
    
    /// Checks for exact compliance to the given configuration.
    ///
    /// In contrast to the quick compliance, in order to check for the exact compliance this method needs a math basis.
    /// This means the checking happens only after complex calculations, but the compliance is accurate.
    ///
    /// - Note: This method checks for the presence or absence of chars and for their order.
    /// - Returns: `True` if the basis satisfies all the conditions; otherwise, `false`.
    @inlinable @inline(__always)
    internal static func checkExactCompliance(for basis: MathCore.Basis, to configuration: AtomicConfiguration) -> Bool {
        
        guard !basis.subsequence.isEmpty else { return false }
        
        let accurateLength = basis.sourceSequence.count
        if let requiredCount = configuration.requiredQuantityOfCorrectChars?.calculate(for: accurateLength) {
            let countOfMatchingChars = basis.subsequence.count
            guard requiredCount <= countOfMatchingChars else { return false }
        }
        
        let comparedLength = basis.sequence.count
        if let acceptableCount = configuration.acceptableQuantityOfWrongChars?.calculate(for: comparedLength) {
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
        
        if let requiredCount = configuration.requiredQuantityOfCorrectChars?.calculate(for: accurateText.count) {
            guard requiredCount <= countOfCommonChars else { return false }
        }
        
        if let acceptableCount = configuration.acceptableQuantityOfWrongChars?.calculate(for: comparedText.count) {
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
    @inlinable
    internal static func plainAtomicText(from text: String, ofType type: AtomicCharacter.AtomicType, with configuration: AtomicConfiguration) -> AtomicText {
        var atomicText = AtomicText(from: text, type: type)
        if let letterCaseAction = configuration.letterCaseAction {
            switch letterCaseAction {
            case .leadTo(let version): atomicText.lead(to: version)
            case .compare: break
            }
        }
        return atomicText
    }
    
    
    // MARK: - Init
    
    /// Creates a basic converter instance.
    private init() {}
    
}
