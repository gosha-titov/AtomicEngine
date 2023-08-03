internal final class MathFrame {
    
    internal typealias Sequence = [Int]
    internal typealias OptionalSequence = [Int?]
    internal typealias Subsequence = [Int]
    
    internal typealias Pair = (sequence: OptionalSequence, subsequence: Subsequence)
    
    
    // MARK: - Make Raw Pairs
        
    /// Makes raw pairs by finding lises of the given sequences.
    ///
    ///     let rawSequences = [
    ///         [nil, 1, 2, 4, 1], // lis: [1, 2, 4]
    ///         [nil, 1, 2, 4, 3], // lis: [1, 2, 3]
    ///         [nil, 3, 2, 4, 3]  // lis: [2, 3]
    ///     ]
    ///
    ///     let rawPairs = makeRawPairs(from: rawSequences)
    ///     /* [([nil, 1, 2, 4, 1], [1, 2, 4]),
    ///         ([nil, 1, 2, 4, 3], [1, 2, 3])] */
    ///
    /// - Note: The result will contain pairs with the max lis length.
    /// - Returns: Pairs of sequence and its subsequence.
    internal static func makeRawPairs(from rawSequences: [OptionalSequence]) -> [Pair] {
        
        var pairs = [Pair]()
        var maxCount = Int()
        
        for rawSequence in rawSequences {
            let sequence = rawSequence.compactMap { $0 }
            let subsequence = findLis(of: sequence)
            if subsequence.count >= maxCount {
                pairs.append( (rawSequence, subsequence) )
                maxCount = subsequence.count
            }
        }
        
        return pairs.filter { $0.subsequence.count == maxCount }
    }
    
    
    // MARK: - Generate Raw Sequences

    /// Generates all possible char placements for `comparedText` relying on `accurateText`.
    ///
    /// This method searches for the placements of the same char of `accurateText` for each char in `comparedText`.
    ///
    ///     let accurateText = "robot"
    ///     let comparedText = "gotob"
    ///
    ///     let rawSequences = generateRawSequences(
    ///         for: comparedText,
    ///         relyingOn: accurateText
    ///     )
    ///     /* [[nil, 1, 4, 1, 2],
    ///         [nil, 1, 4, 3, 2],
    ///         [nil, 3, 4, 3, 2]] */
    ///
    /// - Note: The raw sequences are arranged in increasing order. The indexes of the same chars are arranged in a non-decreasing order.
    /// - Returns: The sequences where elemens are indexes of chars in `accurateText`.
    internal static func generateRawSequences(for comparedText: String, relyingOn accurateText: String) -> [OptionalSequence] {
        
        var rawSequences = [OptionalSequence]()
        
        let dict = charPositions(of: accurateText)
        let comparedText = comparedText.lowercased()
        var cache = [Character: [Int]]()
        
        func recursion(_ sequence: OptionalSequence, _ index: Int) -> Void {
            guard index < comparedText.count else {
                rawSequences.append(sequence)
                return
            }
            let char = comparedText[index]
            if let elements = dict[char] {
                for element in elements {
                    if let array = cache[char], let last = array.last {
                        guard element >= last else { continue }
                        cache[char]!.append(element)
                    } else {
                        cache[char] = [element]
                    }
                    recursion(sequence + [element], index + 1)
                    cache[char]!.removeLast()
                }
            } else {
                recursion(sequence + [nil], index + 1)
            }
        }
        
        recursion([], 0)
        
        return rawSequences
    }
    
    
    // MARK: - Char Positions
        
    /// Finds for each char all its indexes where it's placed in the given text.
    ///
    ///     let text = "Robot"
    ///     let dict = charPositions(of: text)
    ///     // ["r": [0], "o": [1, 3], "b": [2], "t": [4]]
    ///
    /// - Note: Letter case does not affect anything, because the text is changed to a lowercase version.
    /// - Complexity: O(*n*), where *n* is the length of the text.
    /// - Returns: A dictionary where each char contains its own indexes.
    internal static func charPositions(of text: String) -> [Character: [Int]] {
        
        var dict = [Character: [Int]]()
        
        for (index, char) in text.lowercased().enumerated() {
            if dict.hasKey(char) {
                dict[char]!.append(index)
            } else {
                dict[char] = [index]
            }
        }
        
        return dict
    }
    
    
    // MARK: - Find Lis
    
    /// Finds the longest-increasing-subsequence of the given sequence.
    ///
    /// It's the main method on which all other operations are based.
    ///
    ///     let sequence = [2, 6, 0, 8, 1, 3, 1]
    ///     let subsequence = findLis(of: sequence) // [0, 1, 3]
    ///
    /// The example sequence has two *lises*: `[2, 6, 8]` and `[0, 1, 3]`.
    /// This method returns always the smallest one, that is `[0, 1, 3]`.
    /// - Complexity: In the worst case, O(*n* log *n*), where *n* is the length of the sequence.
    /// - Returns: The longest increasing subsequence of the sequence.
    internal static func findLis(of sequence: Sequence) -> Subsequence {
        
        guard sequence.count > 1 else { return sequence }
        
        // The array contains the found lises of each length for the current step.
        // Lises are ordered by the last element. The length of next lis is one longer.
        // Therefore, the longest lis is the last one.
        //
        // Example: sequence = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7]
        // At the last step, lises will be [[0], [0, 1], [0, 1, 3], [0, 1, 3, 7], [0, 2, 6, 9, 11]]
        var lises: [Subsequence] = [[sequence.first!]]
        
        for element in sequence[1...] {
            
            var lowerBound = 0, upperBound = lises.count - 1
            var index: Int { lowerBound }
            
            // Lises are ordered by the last element.
            // Shift the boundaries to the first element that is bigger than the current one.
            // Use binary search which is the fastest.
            while lowerBound < upperBound {
                let middle = lowerBound + (upperBound - lowerBound) / 2
                let middleElement = lises[middle].last!
                if middleElement == element { lowerBound = middle; break }
                if middleElement > element  { upperBound = middle }
                else { lowerBound = middle + 1 }
            }
            
            // If all elements are smaller, then we add a new lis.
            // If all elements are bigger, then we change the first lis.
            // In any other case, we change the selected lis.
            if index == lises.count - 1, element > lises[index].last! {
                lises.append(lises[index] + [element])
            } else if index == 0 {
                lises[0] = [element]
            } else {
                lises[index] = lises[index - 1] + [element]
            }
        }
        
        return lises.last!
    }
    
    
    // MARK: - Init
    
    /// Creates a math frame instance.
    private init() {}
    
}
