import XCTest
@testable import TypoHunt

final class TextFormerTests: XCTestCase {

    // MARK: - TextFormer.applying(_:to:)
    
    func testApplyingConfiguration() -> Void {
        
        var atomicText = AtomicText()
        var configuration = AtomicConfiguration()
        var result: AtomicText {
            return TextFormer.applying(configuration, to: atomicText)
        }
        
        atomicText = []
        XCTAssertEqual(result, [])
        
        atomicText = [
            AtomicCharacter("a", type: .correct),
            AtomicCharacter("B", type: .missing),
            AtomicCharacter("c", type: .extra  )
        ]
        
        configuration.letterCaseAction = .compare
        XCTAssertEqual(result, [
            AtomicCharacter("a", type: .correct),
            AtomicCharacter("B", type: .missing),
            AtomicCharacter("c", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.capitalized)
        XCTAssertEqual(result, [
            AtomicCharacter("A", type: .correct),
            AtomicCharacter("b", type: .missing),
            AtomicCharacter("c", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.uppercase)
        XCTAssertEqual(result, [
            AtomicCharacter("A", type: .correct),
            AtomicCharacter("B", type: .missing),
            AtomicCharacter("C", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.lowercase)
        XCTAssertEqual(result, [
            AtomicCharacter("a", type: .correct),
            AtomicCharacter("b", type: .missing),
            AtomicCharacter("c", type: .extra  )
        ])
        
    }

}
