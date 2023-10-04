
![TypoHunt_logo_2](https://github.com/gosha-titov/TypoHunt/assets/108375163/a2617dd6-4d3c-49ef-b150-54dc293a90e6)

# Description

`TypoHunt` is a framework for finding typos (missing, wrong, swapped or extra chars) by comparing the user text with the accurate one specified in advance.
It creates math models based on the given texts, applies many complicated algorithms and then makes the math result user-friendly by converting it back to a textual representation. 

This direct approach allows you to find typos of any complexity in the user text, and therefore allows you to draw the necessary conclusions.
But the more complex (longer and more monotonous) the source text and the more mistakes the user makes, the longer the execution time.
For this reason, you can use a bit different approach when texts are divided into sentences and sentences into words.
There is only one drawback: if the user put a space in the wrong place or put it accidentally, then there is an inaccuracy of the result.


# Installation

In order to install `TypoHunt`, you add the following url in Xcode with the Swift Package Manager.

```
https://github.com/gosha-titov/TypoHunt.git
```


# Usage

Firstly, you can define a new class that subclasses the `THValidator` class in order to have only one (singleton) instance:

```swift
import TypoHunt

/// A validator that can check for typos and mistakes in a text relying on another text.
final class Validator: THValidator {

    /// The singleton validator instance.
    static let shared: Validator = {
        // A configuration that is applied during the creation of the text.
        var configuration = THConfiguration()
        configuration.letterCaseAction = .leadTo(.capitalized)
        configuration.requiredQuantityOfCorrectChars = .high
        configuration.acceptableQuantityOfWrongChars = .one
        let validator = Validator(configuration: configuration)
        return validator
    }()

}
```

Then you create the `THDisplayView` instance that will display a checked text, 
and add the method that handles a user input text by using the checking method:

```swift
import TypoHunt
import UIKit

final class ViewController: UIViewController {

    /// The view that can display a text containing typos and mistakes, 
    /// such as missing, misspell, swapped or extra characters.
    let displayView = THDisplayView()

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
            andHandleResult: { [weak self] text in
                // The checking process performs asynchronously on the "com.typo-hunt.main" queue
                // and then this handling closure is always called asynchronously on the DispatchQueue.main queue
                // That is, it allows you to update your UI components
                self?.displayView.text = text
            }
        )
    }

}
```
