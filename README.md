
![LetterMatter_logo](https://github.com/gosha-titov/LetterMatter/assets/108375163/6329277b-dc60-49a3-83a6-f2cd231e6858)

# Description

`LetterMatter` is a framework for finding typos (missing, wrong, swapped or extra chars) by comparing the user text with the accurate one specified in advance.
It creates math models based on the given texts, applies many complicated algorithms and then makes the math result user-friendly by converting it back to a textual representation. 

This direct approach allows you to find typos of any complexity in the user text, and therefore allows you to draw the necessary conclusions.
But the more complex (longer and more monotonous) the source text and the more mistakes the user makes, the longer the execution time.
For this reason, you can use a bit different approach when texts are divided into sentences and sentences into words.
There is only one drawback: if the user put a space in the wrong place or put it accidentally, then there is an inaccuracy of the result.


# Installation

In order to install `LetterMatter`, you add the following url in Xcode with the Swift Package Manager.

```
https://github.com/gosha-titov/LetterMatter.git
```


# Usage

Firstly, you can define a new class that subclasses the `LMValidator` class in order to have only one (singleton) instance:

```swift
import LetterMatter

/// A validator that can check for typos and mistakes in a text relying on another text.
final class Validator: LMValidator {

    /// The singleton validator instance.
    static let shared: Validator = {
        // A configuration that is applied during the creation of the text.
        var configuration = LMConfiguration()
        configuration.letterCaseAction = .leadTo(.capitalized)
        configuration.requiredQuantityOfCorrectChars = .high
        configuration.acceptableQuantityOfWrongChars = .one
        let validator = Validator(configuration: configuration)
        return validator
    }()

}
```

Then you create the `LMDisplayView` instance that will display a checked text, 
and add the method that handles a user input text by using the checking method:

```swift
import LetterMatter
import UIKit

final class ViewController: UIViewController {

    /// The view that can display a text containing typos and mistakes, 
    /// such as missing, misspell, swapped or extra characters.
    let displayView = LMDisplayView()

    /// The correct text that a user should enter
    let correctAnswer = "Hello"

    ...

    override func viewDidLoad() -> Void {
        super.viewDidLoad()
        ...
        view.addSubview(displayView)
    }

    func checkUserAnswerAndDisplayResult(_ userAnswer: String) -> Void {
        // Checks for all typos and mistakes in the given text relying on the accurate text, asynchronously.
        Validator.shared.checkForTyposAndMistakes(
            in: userAnswer, relyingOn: correctAnswer, 
            andHandleResult: { [weak self] checkedText in
                // The checking process performs asynchronously on the "com.letter-matter.main" queue
                // and then this handling closure is always called asynchronously on the DispatchQueue.main queue
                // That is, it allows you to update your UI components here
                self?.displayView.text = checkedText
            }
        )
    }

}
```
