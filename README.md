
![TypoHunt_logo_2](https://github.com/gosha-titov/TypoHunt/assets/108375163/a2617dd6-4d3c-49ef-b150-54dc293a90e6)

# Description

`TypoHunt` is a framework for finding typos (missing, wrong, swapped or extra chars) by comparing the user text with the accurate one specified in advance.
It creates math models based on the given texts, applies many complicated algorithms and then makes the math result user-friendly by converting it back to a textual representation. 

This direct approach allows you to find typos of any complexity in the user text, and therefore allows you to draw the necessary conclusions.
But the more complex (longer and more monotonous) the source text and the more mistakes the user makes, the longer the execution time.
For this reason, you can use a bit different approach when texts are divided into sentences and sentences into words.
There is only one drawback: if the user put a space in the wrong place or put it accidentally, then there is an inaccuracy of the result.


# Usage

Firstly, you can define a new class that subclasses the `THTypoFinder` class in order to have only one (singleton) instance:

```swift
import TypoHunt

final class TypoFinder: THTypoFinder {

  /// The singleton typo finder instance.
  static let shared: TypoFinder = {
    let configuration = THConfiguration()
    configuration.letterCaseAction = .leadTo(.capitalized)
    configuration.requiredQuantityOfCorrectChars = .high
    configuration.acceptableQuantityOfWrongChars = .one
    let finder = TypoFinder()
    finder.configuration = configuration
    return finder
  }()

}
```

Then you create the `THTextView` instance that will display a user checked text, 
and add the method that handles a user input text by using the finding method:

```swift
import TypoHunt
import UIKit

final class ViewController: UIViewController {

  // The view that can display a `THText`
  let textView = THTextView()

  // The correct text that a user should enter
  let answer = "Hello"

...

  override func viewDidLoad() -> Void {
    super.viewDidLoad()
    ...
    view.addSubview(textView)
  }

  func checkUserInputTextAndDisplayResult(_ userText: String) -> Void {
    TypoFinder.shared.findTypos(
      in: userText, relyingOn: answer, 
      andHandleResult: { [weak self] text in
        // The typo finding process performs asynchronously on the "com.typo-hunt.main" queue
        // and then this handling closure is called asynchronously on the DispatchQueue.main queue
        // That is, it allows you to update your UI components
        self?.textView.text = text
      }
    )
  }

}
```
