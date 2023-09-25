import XCTest
@testable import TypoHunt

final class TextFormerTests: XCTestCase {
    
    
    // MARK: - THTextFormer.plainText(from:ofType:with:)
    
    func testPlainText() -> Void {
        
        var text = String()
        var type = THCharacter.CharacterType()
        var configuration = THConfiguration()
        var result: THText {
            return THTextFormer.plainText(from: text, ofType: type, with: configuration)
        }
        
        text = ""
        XCTAssertEqual(result, [])
        
        text = "aBc"; type = .correct
        
        XCTAssertEqual(result, [
            THCharacter("a", type: .correct),
            THCharacter("B", type: .correct),
            THCharacter("c", type: .correct)
        ])
        
        configuration.letterCaseAction = .compare
        XCTAssertEqual(result, [
            THCharacter("a", type: .correct),
            THCharacter("B", type: .correct),
            THCharacter("c", type: .correct)
        ])
        
        configuration.letterCaseAction = .leadTo(.capitalized)
        XCTAssertEqual(result, [
            THCharacter("A", type: .correct),
            THCharacter("b", type: .correct),
            THCharacter("c", type: .correct)
        ])
        
        configuration.letterCaseAction = .leadTo(.uppercase); type = .extra
        XCTAssertEqual(result, [
            THCharacter("A", type: .extra),
            THCharacter("B", type: .extra),
            THCharacter("C", type: .extra)
        ])
        
        configuration.letterCaseAction = .leadTo(.lowercase); type = .missing
        XCTAssertEqual(result, [
            THCharacter("a", type: .missing),
            THCharacter("b", type: .missing),
            THCharacter("c", type: .missing)
        ])
        
    }
    

    // MARK: - THTextFormer.applying(_:to:)
    
    func testApplyingConfiguration() -> Void {
        
        var text = THText()
        var configuration = THConfiguration()
        var result: THText {
            return THTextFormer.applying(configuration, to: text)
        }
        
        text = []
        XCTAssertEqual(result, [])
        
        text = [THCharacter("a", type: .misspell("b"))]
        configuration.letterCaseAction = .leadTo(.capitalized)
        XCTAssertEqual(result, [THCharacter("A", type: .misspell("B"))])
        
        text = [THCharacter("a", type: .misspell("b"))]
        configuration.letterCaseAction = .leadTo(.uppercase)
        XCTAssertEqual(result, [THCharacter("A", type: .misspell("B"))])
        
        text = [THCharacter("A", type: .misspell("B"))]
        configuration.letterCaseAction = .leadTo(.lowercase)
        XCTAssertEqual(result, [THCharacter("a", type: .misspell("b"))])
        
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
