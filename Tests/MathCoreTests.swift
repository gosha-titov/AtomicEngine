import XCTest
@testable import LetterMatter

final class THMathCoreTests: XCTestCase {
    
    typealias OptionalSequence = LMMathCore.OptionalSequence
    typealias Subsequence = LMMathCore.Subsequence
    typealias Sequence = LMMathCore.Sequence
    typealias Basis = LMMathCore.Basis
    typealias Pair = LMMathCore.Pair
    
    func testTime() -> Void {
        
        // Used to measure execition time
        // Just to see the difference between any updates more clearly
        
//        var comparedText = String()
//        var accurateText = String()
//
//        accurateText = "abababababab"
//        comparedText = "babababababa"
//
//        ExecutionTime.measure {
//            let _ = THMathCore.calculateBasis(for: comparedText, relyingOn: accurateText)
//        }
        
    }
    
    
    // MARK: - LMMathCore.calculateBasis(for:relyingOn:)
    
    func testCalculateBasis() -> Void {
        
        var comparedText = String()
        var accurateText = String()
        var basis: Basis {
            return LMMathCore.calculateBasis(for: comparedText, relyingOn: accurateText)
        }
        
        XCTAssertEqual(basis, Basis([], [], []))
        
        comparedText = ""; accurateText = "ab"
        XCTAssertEqual(basis, Basis(sourceSequence: [0, 1], sequence: [], subsequence: []))
        
        comparedText = "ab"; accurateText = ""
        XCTAssertEqual(basis, Basis(sourceSequence: [], sequence: [nil, nil], subsequence: []))
        
        comparedText = "ab"; accurateText = "ab"
        XCTAssertEqual(basis, Basis(sourceSequence: [0, 1], sequence: [0, 1], subsequence: [0, 1]))
        
        comparedText = "ab"; accurateText = "cd"
        XCTAssertEqual(basis, Basis(sourceSequence: [0, 1], sequence: [nil, nil], subsequence: []))
        
        comparedText = "Ab"; accurateText = "aB"
        XCTAssertEqual(basis, Basis(sourceSequence: [0, 1], sequence: [0, 1], subsequence: [0, 1]))
            
        comparedText = "bac"; accurateText = "abc"
        XCTAssertEqual(basis, Basis(
            sourceSequence: [0, 1, 2],
            sequence:       [1, 0, 2],
            subsequence:    [   0, 2]
        ))
        
        comparedText = "3a1cb2"; accurateText = "abc123"
        XCTAssertEqual(basis, Basis(
            sourceSequence: [0, 1, 2, 3, 4, 5],
            sequence:       [5, 0, 3, 2, 1, 4],
            subsequence:    [   0,       1, 4]
        ))
        
        comparedText = "abc"; accurateText = "AaBb"
        XCTAssertEqual(basis, Basis(
            sourceSequence: [0, 1, 2, 3],
            sequence:       [0, 2, nil ],
            subsequence:    [0, 2      ]
        ))
        
        comparedText = "aaaa1bbbb"; accurateText = "aaaa2bbbb"
        XCTAssertEqual(basis, Basis(
            sourceSequence: [0, 1, 2, 3,  4,  5, 6, 7, 8],
            sequence:       [0, 1, 2, 3, nil, 5, 6, 7, 8],
            subsequence:    [0, 1, 2, 3,      5, 6, 7, 8]
        ))
        
        comparedText = "abbc"; accurateText = "abbbc"
        XCTAssertEqual(basis, Basis(
            sourceSequence: [0, 1, 2, 3, 4],
            sequence:       [0, 1, 2,    4],
            subsequence:    [0, 1, 2,    4]
        ))
        
    }
    
    
    // MARK: - LMMathCore.pickBestPair(among:)
    
    func testPickBestPair() -> Void {
            
        var rawPairs = [Pair]()
        var bestPair: Pair {
            return LMMathCore.pickBestPair(among: rawPairs)
        }
        
        rawPairs = []
        XCTAssertEqual(bestPair, Pair())
        
        rawPairs = [
            Pair(sequence: [0, 1, 2], subsequence: [0, 1, 2])
        ]
        XCTAssertEqual(bestPair, rawPairs[0])
        
        rawPairs = [
            Pair(sequence: [1, 4, 2], subsequence: [1, 2]),
            Pair(sequence: [1, 4, 3], subsequence: [1, 3])
        ]
        XCTAssertEqual(bestPair, rawPairs[0])
        
        rawPairs = [
            Pair(sequence: [nil, 1], subsequence: [1]),
            Pair(sequence: [nil, 2], subsequence: [2])
        ]
        XCTAssertEqual(bestPair, rawPairs[0])
        
        rawPairs = [
            Pair(sequence: [nil, 1, 5, 6], subsequence: [1, 5, 6]),
            Pair(sequence: [nil, 2, 4, 5], subsequence: [2, 4, 5]),
            Pair(sequence: [nil, 0, 2, 7], subsequence: [0, 2, 7]),
            Pair(sequence: [nil, 1, 2, 6], subsequence: [1, 2, 6]),
            Pair(sequence: [nil, 2, 3, 5], subsequence: [2, 3, 5])
        ]
        XCTAssertEqual(bestPair, rawPairs[2])
    }
    
    
    // MARK: - LMMathCore.makeRawPairs(from:)
    
    func testMakeRawPairs() -> Void {
        
        var rawSequences = [OptionalSequence]()
        var rawPairs: [Pair] {
            return LMMathCore.makeRawPairs(from: rawSequences)
        }
        
        rawSequences = []
        XCTAssertEqual(rawPairs, [])
        
        rawSequences = [ [nil] ]
        XCTAssertEqual(rawPairs, [
            Pair(sequence: [nil], subsequence: [])
        ])
        
        rawSequences = [ [0, 1, 2] ]
        XCTAssertEqual(rawPairs, [
            Pair(sequence: [0, 1, 2], subsequence: [0, 1, 2])
        ])
        
        rawSequences = [ [0, 2, 1], [0, 2, 3] ]
        XCTAssertEqual(rawPairs, [
            Pair(sequence: [0, 2, 3], subsequence: [0, 2, 3])
        ])
        
        rawSequences = [ [1, nil, 2], [1, nil, 3] ]
        XCTAssertEqual(rawPairs, [
            Pair(sequence: [1, nil, 2], subsequence: [1, 2]),
            Pair(sequence: [1, nil, 3], subsequence: [1, 3])
        ])
        
        rawSequences = [ [nil, 2, 0, 4, nil], [nil, 2, 3, 4, nil] ]
        XCTAssertEqual(rawPairs, [
            Pair(sequence: [nil, 2, 3, 4, nil], subsequence: [2, 3, 4])
        ])
        
    }
    
    
    // MARK: - LMMathCore.generateRawSequences(for:relyingOn:)
        
    func testGenerateRawSequences() -> Void {
            
        var comparedText = String()
        var accurateText = String()
        var rawSequences: [OptionalSequence] {
            return LMMathCore.generateRawSequences(for: comparedText, relyingOn: accurateText)
        }
        
        comparedText = ""; accurateText = ""
        XCTAssertEqual(rawSequences, [[]])
        
        comparedText = ""; accurateText = "abc"
        XCTAssertEqual(rawSequences, [[]])
        
        comparedText = "abc"; accurateText = ""
        XCTAssertEqual(rawSequences, [ [nil, nil, nil] ])
        
        comparedText = "abc"; accurateText = "def"
        XCTAssertEqual(rawSequences, [ [nil, nil, nil] ])
        
        comparedText = "abc"; accurateText = "abc"
        XCTAssertEqual(rawSequences, [ [0, 1, 2] ])
        
        comparedText = "Abc"; accurateText = "aBc"
        XCTAssertEqual(rawSequences, [ [0, 1, 2] ])
        
        comparedText = "yy"; accurateText = "ay"
        XCTAssertEqual(rawSequences, [ [1, 1] ])
        
        comparedText = "abcd"; accurateText = "dcba"
        XCTAssertEqual(rawSequences, [ [3, 2, 1, 0] ])
        
        comparedText = "abac"; accurateText = "caba"
        XCTAssertEqual(rawSequences, [ [1, 2, 1, 0], [1, 2, 3, 0], [3, 2, 3, 0] ])
        
        comparedText = "aa"; accurateText = "aa"
        XCTAssertEqual(rawSequences, [ [0, 1] ])
        
        comparedText = "aaaaa"; accurateText = "aaaaa"
        XCTAssertEqual(rawSequences, [ [0, 1, 2, 3, 4] ])
        
        comparedText = "3aaa12"; accurateText = "12aaa3"
        XCTAssertEqual(rawSequences, [ [5, 2, 3, 4, 0, 1] ])
        
        comparedText = "2aaa1a"; accurateText = "1aaaa2"
        XCTAssertEqual(rawSequences, [ [5, 1, 2, 3, 0, 3], [5, 1, 2, 3, 0, 4] ])
        
    }
    
    
    // MARK: - LMMathCore.countCommonChars(between:and:)
    
    func testCountCommonChars() -> Void {
        
        var text1 = String()
        var text2 = String()
        var count: Int {
            return LMMathCore.countCommonChars(between: text1, and: text2)
        }
        
        text1 = ""; text2 = ""
        XCTAssertEqual(count, 0)
        
        text1 = "aaabbb"; text2 = "bbbaaa"
        XCTAssertEqual(count, 6)
        
        text1 = ""; text2 = "abc"
        XCTAssertEqual(count, 0)
        
        text1 = "abc"; text2 = ""
        XCTAssertEqual(count, 0)
        
        text1 = "abc"; text2 = "abc"
        XCTAssertEqual(count, 3)
        
        text1 = "Abc"; text2 = "aBc"
        XCTAssertEqual(count, 3)
        
        text1 = "abc"; text2 = "cba"
        XCTAssertEqual(count, 3)
        
        text1 = "Ab$c!"; text2 = "Ba$C?"
        XCTAssertEqual(count, 4)
        
        text1 = "#$%"; text2 = "$@#"
        XCTAssertEqual(count, 2)
        
        text1 = "AbAC"; text2 = "acBA"
        XCTAssertEqual(count, 4)
    }

    
    // MARK: - LMMathCore.charPositions(of:)
    
    func testCharPositions() -> Void {
        
        var text = String()
        var dict: [Character: [Int]] {
            return LMMathCore.charPositions(of: text)
        }
        
        text = ""
        XCTAssertEqual(dict, [:])
        
        text = "7"
        XCTAssertEqual(dict, ["7": [0]])
        
        text = ":::::"
        XCTAssertEqual(dict, [":": [0, 1, 2, 3, 4]])
        
        text = " 1 3"
        XCTAssertEqual(dict, [" ": [0, 2], "1": [1], "3": [3]])
        
        text = "abc"
        XCTAssertEqual(dict, ["a": [0], "b": [1], "c": [2]])
        
        text = "AbcaBC"
        XCTAssertEqual(dict, ["a": [0, 3], "b": [1, 4], "c": [2, 5]])
        
        text = "1!,@1"
        XCTAssertEqual(dict, ["1": [0, 4], "!": [1], ",": [2], "@": [3]])
    }
    
    
    // MARK: - LMMathCore.findLis(of:)
    
    func testFindLis() {
        
        var sequence = Sequence()
        var subsequence: Subsequence {
            return LMMathCore.findLIS(of: sequence)
        }
        
        sequence = []
        XCTAssertEqual(subsequence, [])

        sequence = [1]
        XCTAssertEqual(subsequence, [1])

        sequence = [1, 0]
        XCTAssertEqual(subsequence, [0])

        sequence = [1, 0, 2, 1, 3]
        XCTAssertEqual(subsequence, [0, 1, 3])
        
        sequence = [2, 1, 4, 3, 6, 5]
        XCTAssertEqual(subsequence, [1, 3, 5])
        
        sequence = [2, 6, 0, 8, 1, 3, 1]
        XCTAssertEqual(subsequence, [0, 1, 3])
        
        sequence = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15]
        XCTAssertEqual(subsequence, [0, 2, 6, 9, 11, 15])
    }
    
}
