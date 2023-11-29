import XCTest
@testable import LetterMatter

final class TextFormerTests: XCTestCase {
    
    // MARK: LMTextFormer.checkQuickCompliance(for:relyingOn:to:)
    
    func testCheckQuickCompliance() -> Void {
        
        var comparedText = String()
        var accurateText = String()
        var configuration = LMConfiguration()
        var result: Bool {
            return LMTextFormer.checkQuickCompliance(for: comparedText, relyingOn: accurateText, to: configuration)
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
    
    
    // MARK: - LMTextFormer.plainText(from:ofType:with:)
    
    func testPlainText() -> Void {
        
        var text = String()
        var type = LMCharacter.CharacterType()
        var configuration = LMConfiguration()
        var result: LMText {
            return LMTextFormer.plainText(from: text, ofType: type, with: configuration)
        }
        
        text = ""
        XCTAssertEqual(result, [])
        
        text = "aBc"; type = .correct
        
        XCTAssertEqual(result, [
            LMCharacter("a", type: .correct),
            LMCharacter("B", type: .correct),
            LMCharacter("c", type: .correct)
        ])
        
        configuration.letterCaseAction = .compare
        XCTAssertEqual(result, [
            LMCharacter("a", type: .correct),
            LMCharacter("B", type: .correct),
            LMCharacter("c", type: .correct)
        ])
        
        configuration.letterCaseAction = .leadTo(.capitalized)
        XCTAssertEqual(result, [
            LMCharacter("A", type: .correct),
            LMCharacter("b", type: .correct),
            LMCharacter("c", type: .correct)
        ])
        
        configuration.letterCaseAction = .leadTo(.uppercase); type = .extra
        XCTAssertEqual(result, [
            LMCharacter("A", type: .extra),
            LMCharacter("B", type: .extra),
            LMCharacter("C", type: .extra)
        ])
        
        configuration.letterCaseAction = .leadTo(.lowercase); type = .missing
        XCTAssertEqual(result, [
            LMCharacter("a", type: .missing),
            LMCharacter("b", type: .missing),
            LMCharacter("c", type: .missing)
        ])
        
    }
    

    // MARK: - LMTextFormer.applying(_:to:)
    
    func testApplyingConfiguration() -> Void {
        
        var text = LMText()
        var configuration = LMConfiguration()
        var result: LMText {
            return LMTextFormer.applying(configuration, to: text)
        }
        
        text = []
        XCTAssertEqual(result, [])
        
        text = [LMCharacter("a", type: .misspell("b"))]
        configuration.letterCaseAction = .leadTo(.capitalized)
        XCTAssertEqual(result, [LMCharacter("A", type: .misspell("B"))])
        
        text = [LMCharacter("a", type: .misspell("b"))]
        configuration.letterCaseAction = .leadTo(.uppercase)
        XCTAssertEqual(result, [LMCharacter("A", type: .misspell("B"))])
        
        text = [LMCharacter("A", type: .misspell("B"))]
        configuration.letterCaseAction = .leadTo(.lowercase)
        XCTAssertEqual(result, [LMCharacter("a", type: .misspell("b"))])
        
        text = [
            LMCharacter("a", type: .correct),
            LMCharacter("B", type: .missing),
            LMCharacter("c", type: .extra  )
        ]
        
        configuration.letterCaseAction = .compare
        XCTAssertEqual(result, [
            LMCharacter("a", type: .correct),
            LMCharacter("B", type: .missing),
            LMCharacter("c", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.capitalized)
        XCTAssertEqual(result, [
            LMCharacter("A", type: .correct),
            LMCharacter("b", type: .missing),
            LMCharacter("c", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.uppercase)
        XCTAssertEqual(result, [
            LMCharacter("A", type: .correct),
            LMCharacter("B", type: .missing),
            LMCharacter("C", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.lowercase)
        XCTAssertEqual(result, [
            LMCharacter("a", type: .correct),
            LMCharacter("b", type: .missing),
            LMCharacter("c", type: .extra  )
        ])
        
    }

}
