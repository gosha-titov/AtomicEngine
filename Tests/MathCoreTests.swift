import XCTest
@testable import AtomicEngine

final class MathCoreTests: XCTestCase {
    
    typealias OptionalSequence = MathCore.OptionalSequence
    typealias Subsequence = MathCore.Subsequence
    typealias Sequence = MathCore.Sequence
    typealias Basis = MathCore.Basis
    typealias Pair = MathCore.Pair

    
    // MARK: - Find Lis
    
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