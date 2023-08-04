import XCTest
@testable import AtomicEngine

final class MathCoreTests: XCTestCase {
    
    typealias OptionalSequence = MathCore.OptionalSequence
    typealias Subsequence = MathCore.Subsequence
    typealias Sequence = MathCore.Sequence
    typealias Basis = MathCore.Basis
    typealias Pair = MathCore.Pair
    
    
    // MARK: - MathCore.calculateBasis(for:relyingOn:)
    
    func testCalculateBasis() -> Void {
            
        typealias Basis = MathCore.Basis
        
        var comparedText = String()
        var accurateText = String()
        var basis: Basis {
            return MathCore.calculateBasis(for: comparedText, relyingOn: accurateText)
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
    
    
    // MARK: - MathCore.pickBestPair(among:)
    
    func testPickBestPair() -> Void {
            
        var rawPairs = [Pair]()
        var bestPair: Pair {
            return MathCore.pickBestPair(among: rawPairs)
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
    
    
    // MARK: - MathCore.makeRawPairs(from:)
    
    func testMakeRawPairs() -> Void {
        
        var rawSequences = [OptionalSequence]()
        var rawPairs: [Pair] {
            return MathCore.makeRawPairs(from: rawSequences)
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
    
    
    // MARK: - MathCore.generateRawSequences(for:relyingOn:)
        
    func testGenerateRawSequences() -> Void {
            
        var comparedText = String()
        var accurateText = String()
        var rawSequences: [OptionalSequence] {
            return MathCore.generateRawSequences(for: comparedText, relyingOn: accurateText)
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
        
        comparedText = "aa"; accurateText = "aa"
        XCTAssertEqual(rawSequences, [ [0, 0], [0, 1], [1, 1] ])
        
        comparedText = "abcd"; accurateText = "dcba"
        XCTAssertEqual(rawSequences, [ [3, 2, 1, 0] ])
        
        comparedText = "abac"; accurateText = "caba"
        XCTAssertEqual(rawSequences, [ [1, 2, 1, 0], [1, 2, 3, 0], [3, 2, 3, 0] ])
    }

    
    // MARK: - MathCore.charPositions(of:)
    
    func testCharPositions() -> Void {
        
        var text = String()
        var dict: [Character: [Int]] {
            return MathCore.charPositions(of: text)
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
    
    
    // MARK: - MathCore.findLis(of:)
    
    func testFindLis() {
        
        var sequence = Sequence()
        var subsequence: Subsequence {
            return MathCore.findLis(of: sequence)
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
