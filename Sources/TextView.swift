#if canImport(UIKit)
import UIKit

open class THTextView: UIView {
    
    // MARK: - Properties
    
    /// The text that is currently displayed, settable.
    public var text = THText()
    
    
    // MARK: UI views
    
    /// The scroll view that contains all labels needed to display the text.
    public let scrollView = UIScrollView()
    
    /// The label that displays correct characters for misspell ones.
    public let upperLabel = UILabel()
    
    /// The label that displays the text.
    public let textLabel = UILabel()
    
    /// The label that displays arrows for swapped characters.
    public let lowerLabel = UILabel()
    
    
    // MARK: UI attributes
    
    /// The size for the monospaced system font that is used for displaying text, settable.
    public var textFontSize: CGFloat?
    
    /// The color that is used to display correct characters, settable.
    public var correctColor: UIColor?
    
    /// The color that is used to display missing characters, settable.
    public var missingColor: UIColor?
    
    /// The color that is used to display swapped characters, settable.
    public var swappedColor: UIColor?
    
    /// The color that is used to display misspell characters, settable.
    public var misspellColor: UIColor?
    
    /// The color that is used to display extra characters, settable.
    public var extraColor: UIColor?
    
}

#endif
