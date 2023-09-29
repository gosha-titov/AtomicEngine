import Foundation

open class THTypoFinder {
    
    // MARK: - Properties
    
    /// The queue that is used for **asynchronous** execution of all finding operations which go strickly after each other.
    ///
    /// This property has the default value that is created in the following way:
    ///
    ///     var queue = DispatchQueue(
    ///         label: "com.typo-hunt.main",
    ///         qos: .userInitiated
    ///     )
    ///
    /// - Note: In the case when this property has no value (`nil`), the typo finding process is performed **asynchronously** on **the main thread**.
    public var queue: DispatchQueue? = .init(label: "com.typo-hunt.main", qos: .userInitiated)
    
    /// The configuration consisting of parameters that are used during the creation of a text.
    ///
    /// The default value of this configuration does not contain any parameters.
    /// So if you need to establish conditions or to lead a text to a certain version, then set your own configuration as in the following example:
    ///
    ///     let configuration = THConfiguration()
    ///     configuration.letterCaseAction = .leadTo(.capitalized)
    ///     finder.configuration = configuration
    ///
    public var configuration = THConfiguration()
    
    
    // MARK: - Methods
    
    /// Finds all typos and mistakes in the given compared text, asynchronously.
    ///
    /// This method executes all operations asynchronously on the `queue` of this finder;
    /// otherwise (if the value is `nil`), does it asynchronously on the main queue.
    ///
    /// The typo finding process uses the configuration that is set for this finder.
    ///
    ///     finder.findTypos(
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
    /// - Parameter accurateText: A text based on which the typo finding proccess performs.
    /// - Parameter handle: A closure that takes a result text as a parameter to handle.
    public final func findTypos(in comparedText: String, relyingOn accurateText: String, andHandleResult handle: @escaping (THText) -> Void) -> Void {
        if let queue {
            queue.async {
                let text = self.findTypos(in: comparedText, relyingOn: accurateText)
                DispatchQueue.main.async {
                    handle(text)
                }
            }
        } else {
            DispatchQueue.main.async {
                let text = self.findTypos(in: comparedText, relyingOn: accurateText)
                handle(text)
            }
        }
    }
    
    /// Finds all typos and mistakes in the given compared text.
    ///
    /// The typo finding process uses the configuration that is set for this finder.
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
    /// - Parameter accurateText: A text based on which the typo finding proccess performs.
    /// - Returns: The created text combined from the given compared and accurate strings.
    public final func findTypos(in comparedText: String, relyingOn accurateText: String) -> THText {
        let formedText = THTextFormer.formText(from: comparedText, relyingOn: accurateText, with: configuration)
        let editedText = THTextEditor.makeTextUserFriendly(formedText, with: configuration)
        return editedText
    }
    
    
    // MARK: - Init
    
    /// Creates a typo finder instance.
    public init() {}
    
}
