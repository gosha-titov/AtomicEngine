import XCTest
@testable import TypoHunt

final class TextFormerTests: XCTestCase {
    
    // MARK: THTextFormer.checkQuickCompliance(for:relyingOn:to:)
    
    func testCheckQuickCompliance() -> Void {
        
        var comparedText = String()
        var accurateText = String()
        var configuration = THConfiguration()
        var result: Bool {
            return THTextFormer.checkQuickCompliance(for: comparedText, relyingOn: accurateText, to: configuration)
        }
        
        XCTAssertEqual(result, false)
        
        comparedText = ""; accurateText = "abc"
        XCTAssertEqual(result, false)
        
        comparedText = "abc"; accurateText = ""
        XCTAssertEqual(result, false)
        
        comparedText = "abc"; accurateText = "123"
        XCTAssertEqual(result, false)
        
        comparedText = "abacaba"; accurateText = "12345c"
        XCTAssertEqual(result, true)
        
        
        // test `.requiredQuantityOfCorrectChars`
        
        comparedText = "aaab"; accurateText = "bccc"
        
        configuration.requiredQuantityOfCorrectChars = .low
        XCTAssertEqual(result, true)
        configuration.requiredQuantityOfCorrectChars = .one
        XCTAssertEqual(result, true)
        
        configuration.requiredQuantityOfCorrectChars = .half
        XCTAssertEqual(result, false)
        configuration.requiredQuantityOfCorrectChars = .two
        XCTAssertEqual(result, false)
        
        comparedText = "aabb"; accurateText = "bbcc"
        
        configuration.requiredQuantityOfCorrectChars = .half
        XCTAssertEqual(result, true)
        configuration.requiredQuantityOfCorrectChars = .two
        XCTAssertEqual(result, true)
        
        configuration.requiredQuantityOfCorrectChars = .high
        XCTAssertEqual(result, false)
        configuration.requiredQuantityOfCorrectChars = .three
        XCTAssertEqual(result, false)
        
        comparedText = "abbb"; accurateText = "bbbc"
        
        configuration.requiredQuantityOfCorrectChars = .high
        XCTAssertEqual(result, true)
        configuration.requiredQuantityOfCorrectChars = .three
        XCTAssertEqual(result, true)
        
        configuration.requiredQuantityOfCorrectChars = .all
        XCTAssertEqual(result, false)
        configuration.requiredQuantityOfCorrectChars = .number(4)
        XCTAssertEqual(result, false)
        
        comparedText = "bbbb"; accurateText = "bbbb"
        
        configuration.requiredQuantityOfCorrectChars = .all
        XCTAssertEqual(result, true)
        configuration.requiredQuantityOfCorrectChars = .number(5)
        XCTAssertEqual(result, true)
        
        comparedText = "a123"; accurateText = "65a4"
        configuration.requiredQuantityOfCorrectChars = .low
        XCTAssertEqual(result, true)
        configuration.requiredQuantityOfCorrectChars = .one
        XCTAssertEqual(result, true)
        
        comparedText = "a12b"; accurateText = "b3a4"
        configuration.requiredQuantityOfCorrectChars = .half
        XCTAssertEqual(result, true)
        configuration.requiredQuantityOfCorrectChars = .two
        XCTAssertEqual(result, true)
        
        comparedText = "ac2b"; accurateText = "b3ac"
        configuration.requiredQuantityOfCorrectChars = .high
        XCTAssertEqual(result, true)
        configuration.requiredQuantityOfCorrectChars = .three
        XCTAssertEqual(result, true)
        
        comparedText = "acbd"; accurateText = "dcab"
        configuration.requiredQuantityOfCorrectChars = .all
        XCTAssertEqual(result, true)
        configuration.requiredQuantityOfCorrectChars = .number(4)
        XCTAssertEqual(result, true)
        
        comparedText = "0b94837a61"; accurateText = "1234567890"
        configuration.requiredQuantityOfCorrectChars = .coefficient(0.8)
        XCTAssertEqual(result, true)
        configuration.requiredQuantityOfCorrectChars = .number(8)
        XCTAssertEqual(result, true)
        
        
        // test `.acceptableQuantityOfWrongChars`
        
        comparedText = "b"; accurateText = "bccc"
        configuration.requiredQuantityOfCorrectChars = nil
        
        configuration.acceptableQuantityOfWrongChars = .high
        XCTAssertEqual(result, true)
        configuration.acceptableQuantityOfWrongChars = .three
        XCTAssertEqual(result, true)
        
        configuration.acceptableQuantityOfWrongChars = .half
        XCTAssertEqual(result, false)
        configuration.acceptableQuantityOfWrongChars = .two
        XCTAssertEqual(result, false)
        
        comparedText = "aabb"; accurateText = "bbcc"
        
        configuration.acceptableQuantityOfWrongChars = .half
        XCTAssertEqual(result, true)
        configuration.acceptableQuantityOfWrongChars = .two
        XCTAssertEqual(result, true)
        
        configuration.acceptableQuantityOfWrongChars = .low
        XCTAssertEqual(result, false)
        configuration.acceptableQuantityOfWrongChars = .one
        XCTAssertEqual(result, false)
        
        comparedText = "abbb"; accurateText = "bbbc"
        
        configuration.acceptableQuantityOfWrongChars = .low
        XCTAssertEqual(result, true)
        configuration.acceptableQuantityOfWrongChars = .one
        XCTAssertEqual(result, true)
        
        configuration.acceptableQuantityOfWrongChars = .coefficient(0.0)
        XCTAssertEqual(result, false)
        configuration.acceptableQuantityOfWrongChars = .zero
        XCTAssertEqual(result, false)
        
        comparedText = "bbbb"; accurateText = "bbbb"
        
        configuration.acceptableQuantityOfWrongChars = .coefficient(0.0)
        XCTAssertEqual(result, true)
        configuration.acceptableQuantityOfWrongChars = .zero
        XCTAssertEqual(result, true)
        
        
        // test both
        
        comparedText = "ab1"; accurateText = "abcd" // "1" is extra and "cd" is missing -> 2 wrong chars
        
        configuration.requiredQuantityOfCorrectChars = .half
        configuration.acceptableQuantityOfWrongChars = .two
        XCTAssertEqual(result, true)
        
        configuration.requiredQuantityOfCorrectChars = .half
        configuration.acceptableQuantityOfWrongChars = .one
        XCTAssertEqual(result, false)
        
        configuration.requiredQuantityOfCorrectChars = .high
        configuration.acceptableQuantityOfWrongChars = .two
        XCTAssertEqual(result, false)
        
    }
    
    
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
