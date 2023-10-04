import Foundation

/// A validator that can check for typos and mistakes in a text relying on another one.
///
/// You usually define a new class that subclasses the `THValidator` class, and create a singleton instance of it.
///
///     import TypoHunt
///
///     final class Validator: THValidator {
///
///         /// The singleton validator instance.
///         static let shared: Validator = {
///             var configuration = THConfiguration()
///             configuration.letterCaseAction = .leadTo(.capitalized)
///             configuration.requiredQuantityOfCorrectChars = .high
///             configuration.acceptableQuantityOfWrongChars = .one
///             return Validator(configuration: configuration)
///         }()
///
///     }
///
/// Then you use its method to check, for example, the user input text with the correct one and display it on the screen:
///
///     func checkUserAnswerAndDisplayResult(_ userAnswer: String) -> Void {
///         Validator.shared.checkForTyposAndMistakes(
///             in: userAnswer, relyingOn: correctAnswer,
///             andHandleResult: { resultText in
///                 displayView.text = resultText
///             }
///         )
///     }
///
/// The validator has two following properties:
/// - **queue**: The queue that is used for asynchronous execution of all checking operations which go strickly after each other;
/// - **configuration**: The configuration consisting of parameters that is used during the creation of a text.
///
/// and has two methods for sync and async executions:
/// - **checkForTyposAndMistakes(in:relyingOn:)** is used for synchronous execution;
/// - **checkForTyposAndMistakes(in:relyingOn:andHandleResult:)** is used for asynchronous execution.
///
open class THValidator {
    
    // MARK: - Properties
    
    /// The queue that is used for **asynchronous** execution of all checking operations which go strickly after each other.
    ///
    /// This property has the default value that is created in the following way:
    ///
    ///     var queue = DispatchQueue(
    ///         label: "com.typo-hunt.main",
    ///         qos: .userInitiated
    ///     )
    ///
    /// - Note: In the case when this property has no value (`nil`), the checking process is performed **asynchronously** on **the main thread**.
    public var queue: DispatchQueue? = .init(label: "com.typo-hunt.main", qos: .userInitiated)
    
    /// The configuration consisting of parameters that is used during the creation of a text.
    ///
    /// The default value of this configuration does not contain any parameters.
    /// So if you need to establish conditions or to lead a text to a certain version, then set your own configuration as in the following example:
    ///
    ///     let configuration = THConfiguration()
    ///     configuration.letterCaseAction = .leadTo(.capitalized)
    ///     validator.configuration = configuration
    ///
    public var configuration: THConfiguration
    
    
    // MARK: - Methods
    
    /// Checks for all typos and mistakes in the given text relying on the accurate one, asynchronously.
    ///
    /// This method executes all operations asynchronously on the `queue` of this validator;
    /// otherwise (if the value is `nil`), does it asynchronously on the main queue.
    ///
    /// The checking process uses the `configuration` that is set for this validator.
    ///
    ///     validator.checkForTyposAndMistakes(
    ///         in: "Hola", relyingOn: "Hello",
    ///         andHandleResult: { text in
    ///             print(text)
    ///         }
    ///     )
    ///     /*[THCharacter("H", type: .correct),
    ///        THCharacter("o", type: .misspell("e")),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("a", type: .misspell("l")),
    ///        THCharacter("o", type: .missing)      ]*/
    ///
    /// - Note: In order for you to update your UI components, this method calls the handling closure **always on the main queue, asynchronously**.
    /// - Parameter comparedText: A text to be compared with `accurateText` in order to find the best set of matching characters.
    /// - Parameter accurateText: A text based on which the checking proccess performs.
    /// - Parameter handle: A closure that takes a result text as a parameter to handle.
    public final func checkForTyposAndMistakes(in comparedText: String, relyingOn accurateText: String, andHandleResult handle: @escaping (THText) -> Void) -> Void {
        if let queue {
            queue.async {
                let text = self.checkForTyposAndMistakes(in: comparedText, relyingOn: accurateText)
                DispatchQueue.main.async {
                    handle(text)
                }
            }
        } else {
            DispatchQueue.main.async {
                let text = self.checkForTyposAndMistakes(in: comparedText, relyingOn: accurateText)
                handle(text)
            }
        }
    }
    
    /// Checks for all typos and mistakes in the given text relying on the accurate one.
    ///
    /// The checking process uses the `configuration` that is set for this validator.
    ///
    ///     let text = finder.findTypos(in: "Hola", relyingOn: "Hello")
    ///     /*[THCharacter("H", type: .correct),
    ///        THCharacter("o", type: .misspell("e")),
    ///        THCharacter("l", type: .correct),
    ///        THCharacter("a", type: .misspell("l")),
    ///        THCharacter("o", type: .missing)      ]*/
    ///
    /// If you need to execute this method asynchronously then call the `findTypos(in:relyingOn:andHandleResult:)` method.
    ///
    /// - Parameter comparedText: A text to be compared with `accurateText` in order to find the best set of matching characters.
    /// - Parameter accurateText: A text based on which the checking proccess performs.
    /// - Returns: The created text combined from the given compared and accurate strings.
    public final func checkForTyposAndMistakes(in comparedText: String, relyingOn accurateText: String) -> THText {
        let formedText = THTextFormer.formText(from: comparedText, relyingOn: accurateText, with: configuration)
        let editedText = THTextEditor.makeTextUserFriendly(formedText, with: configuration)
        return editedText
    }
    
    
    // MARK: - Init
    
    /// Creates a validator instance with the specified configuration.
    /// - Parameter configuration: The configuration consisting of parameters that is used during the creation of a text.
    /// The default value is empty configuration.
    public init(configuration: THConfiguration = .init()) {
        self.configuration = configuration
    }
    
}
