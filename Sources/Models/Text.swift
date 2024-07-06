/// A text consisting of typed characters.
///
///     print(text)
///     /*[LMCharacter("H", type: .correct, hasCorrectLetterCase: false),
///        LMCharacter("e", type: .correct, hasCorrectLetterCase: true),
///        LMCharacter("l", type: .correct, hasCorrectLetterCase: true),
///        LMCharacter("l", type: .correct, hasCorrectLetterCase: true),
///        LMCharacter("o", type: .missing, hasCorrectLetterCase: nil)]*/
///
///     text.isAbsolutelyRight // false
///     text.isCompletelyWrong // false
///     text.countOfTyposAndMistakes // 1
///     text.countOfWrongLetterCases // 1
///
///     print(text.rawValue)
///     // Prints "Hello"
///
public typealias LMText = [LMCharacter]



// MARK: - Behavior Extensions

extension LMText {
    
    /// A boolean value that indicates whether this text has no typos or mistakes.
    ///
    ///     print(text)
    ///     /*[LMCharacter("H", type: .correct, hasCorrectLetterCase: false),
    ///        LMCharacter("i", type: .correct, hasCorrectLetterCase: true)]*/
    ///     text.isAbsolutelyRight // false
    ///
    @inlinable @inline(__always)
    public var isAbsolutelyRight: Bool {
        for char in self {
            guard char.isCorrect else { return false }
            if let letterCaseIsCorrect = char.hasCorrectLetterCase {
                guard letterCaseIsCorrect else { return false }
            }
        }
        return true
    }
    
    /// A boolean value that indicates whether this text has only wrong characters.
    ///
    ///     print(text)
    ///     /*[LMCharacter("i", type: .swapped(position: .left)),
    ///        LMCharacter("h", type: .swapped(position: .right))]*/
    ///     text.isCompletelyWrong // false
    ///
    @inlinable @inline(__always)
    public var isCompletelyWrong: Bool {
        for char in self {
            guard char.isExtra || char.isMissing || char.isMisspell else { return false }
        }
        return true
    }
    
    /// Count of typos and mistakes in this text.
    ///
    /// A misspell, missing or extra char is considered as one mistake;
    /// two swapped chars are considered as one mistake.
    @inlinable @inline(__always)
    public var countOfTyposAndMistakes: Int {
        var count = 0
        var countOfSwappedChars = 0
        for char in self {
            switch char.type {
            case .extra, .missing, .misspell: count += 1
            case .swapped: countOfSwappedChars += 1
            default: break
            }
        }
        return count + countOfSwappedChars / 2
    }
    
    /// Count of characters that have wrong letter case.
    /// - Note: `Nil` values are not considered.
    @inlinable @inline(__always)
    public var countOfWrongLetterCases: Int {
        var count = 0
        for char in self {
            if let letterCaseIsCorrect = char.hasCorrectLetterCase, letterCaseIsCorrect == false {
                count += 1
            }
        }
        return count
    }
    
    /// The string that contains all characters of this text.
    ///
    ///     let text = [
    ///         LMCharacter("H", type: .correct),
    ///         LMCharacter("e", type: .correct),
    ///         LMCharacter("l", type: .correct),
    ///         LMCharacter("l", type: .correct),
    ///         LMCharacter("o", type: .correct)
    ///     ]
    ///     print(text.rawValue)
    ///     // Prints "Hello"
    ///
    @inlinable @inline(__always)
    public var rawValue: String {
        var string = String()
        for char in self {
            string.append(char.rawValue)
            if case let .misspell(correctChar) = char.type {
                string.append(correctChar)
            }
        }
        return string
    }
    
    
    // MARK: Methods
    
    /// Returns a capitalized version of this text.
    ///
    ///     let text = LMText(string: "helLo", type: .correct)
    ///     print(text.capitalized)
    ///     /*[LMCharacter("H", type: .correct),
    ///        LMCharacter("e", type: .correct),
    ///        LMCharacter("l", type: .correct),
    ///        LMCharacter("l", type: .correct),
    ///        LMCharacter("o", type: .correct)]*/
    ///
    @inlinable @inline(__always)
    public var capitalized: LMText {
        guard let first = first?.uppercased else { return [] }
        guard count > 1 else { return [first] }
        return [first] + self[1...].map(\.lowercased)
    }
    
    /// Returns an uppercased version of this text.
    ///
    ///     let text = LMText(string: "Url", type: .correct)
    ///     print(text.uppercased)
    ///     /*[LMCharacter("U", type: .correct),
    ///        LMCharacter("R", type: .correct),
    ///        LMCharacter("L", type: .correct)]*/
    ///
    @inlinable @inline(__always)
    public var uppercased: LMText {
        return map(\.uppercased)
    }
    
    /// Returns a lowercased version of this text.
    ///
    ///     let text = LMText(string: "hELlo", type: .correct)
    ///     print(text.lowercased)
    ///     /*[LMCharacter("h", type: .correct),
    ///        LMCharacter("e", type: .correct),
    ///        LMCharacter("l", type: .correct),
    ///        LMCharacter("l", type: .correct),
    ///        LMCharacter("o", type: .correct)]*/
    ///
    @inlinable @inline(__always)
    public var lowercased: LMText {
        return map(\.lowercased)
    }
    
    
    // MARK: Init
    
    /// Creates a text instance from the given string where all characters are one-type.
    ///
    ///     let text = LMText(string: "Hello", type: .correct)
    ///     /*[LMCharacter("H", type: .correct),
    ///        LMCharacter("e", type: .correct),
    ///        LMCharacter("l", type: .correct),
    ///        LMCharacter("l", type: .correct),
    ///        LMCharacter("o", type: .correct)]*/
    ///
    @inlinable @inline(__always)
    public init(string: String, type: LMCharacter.CharacterType) {
        let text = string.map { LMCharacter($0, type: type) }
        self.init(text)
    }
    
}
