import XCTest
@testable import TypoHunt

final class TextFormerTests: XCTestCase {

    // MARK: - THTextFormer.applying(_:to:)
    
    func testApplyingConfiguration() -> Void {
        
        var text = THText()
        var configuration = THConfiguration()
        var result: THText {
            return THTextFormer.applying(configuration, to: text)
        }
        
        text = []
        XCTAssertEqual(result, [])
        
        text = [
            THCharacter("a", type: .correct),
            THCharacter("B", type: .missing),
            THCharacter("c", type: .extra  )
        ]
        
        configuration.letterCaseAction = .compare
        XCTAssertEqual(result, [
            THCharacter("a", type: .correct),
            THCharacter("B", type: .missing),
            THCharacter("c", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.capitalized)
        XCTAssertEqual(result, [
            THCharacter("A", type: .correct),
            THCharacter("b", type: .missing),
            THCharacter("c", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.uppercase)
        XCTAssertEqual(result, [
            THCharacter("A", type: .correct),
            THCharacter("B", type: .missing),
            THCharacter("C", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.lowercase)
        XCTAssertEqual(result, [
            THCharacter("a", type: .correct),
            THCharacter("b", type: .missing),
            THCharacter("c", type: .extra  )
        ])
        
    }

}
