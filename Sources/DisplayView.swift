#if canImport(UIKit)
import UIKit

/// The view that can display a text containing typos and mistakes, such as missing, misspell, swapped or extra characters.
///
/// This view is a scroll view that consists of three labels to display a text.
///
/// You can manually setup colors by changing values of the following properties:
/// - **completelyCorrectColor** is used when the text is completely correct;
/// - **correctColor** is used for the correct characters;
/// - **warningColor** is used for swapped characters, arrows below them and wrong letter cases;
/// - **wrongColor** is used for extra characters and strikethrough lines;
/// - **missingColor** is used for missing characters.
///
/// You usually change the text property inside the checking method of the validator:
///
///     validator.checkForTyposAndMistakes(
///         in: "Hola", relyingOn: "Hello",
///         andHandleResult: { text in
///             // The handling closure is always called on the main queue
///             // That is, it allows you to update your UI components
///             textView.text = text
///         }
///     )
///
/// In order to get the height of this view, you can use the `computedContentHeight` property:
///
///     let height = displayView.computedContentHeight
///     NSLayoutConstraint.activate([
///         displayView.bottomAnchor.constraint(equalTo: topAnchor, constant: height)
///         ...
///     ])
///
@available(iOS 13.0, *)
open class THDisplayView: UIScrollView {
    
    // MARK: - Properties
    
    /// The text that is currently displayed, settable.
    /// - Note: When you set a new text to this property, it also updates the display.
    public var text = THText() {
        didSet { updateDisplayedText(with: text) }
    }
    
    /// The boolean value that indicates whether the text is centered if its length fits into this display view’s bounding rectangle.
    /// - Note: When you set a new value to this property, it also updates the display.
    public var alignsTextToCenterIfFits = true {
        didSet { setNeedsLayout() }
    }
    
    
    // MARK: UI views
    
    /// The label that displays correct characters for misspell ones.
    public let upperLabel = UILabel()
    
    /// The label that displays the text.
    public let textLabel = UILabel()
    
    /// The label that displays arrows for swapped characters.
    public let lowerLabel = UILabel()
    
    
    // MARK: UI attributes
    
    /// The color that is used to display completely correct text, settable.
    /// - Note: When you set a new color to this property, it also updates the display.
    public var completelyCorrectColor: UIColor = .green {
        didSet { updateDisplay() }
    }
    
    /// The color that is used to display correct characters, settable.
    /// - Note: When you set a new color to this property, it also updates the display.
    public var correctColor: UIColor = .black {
        didSet { updateDisplay() }
    }
    
    /// The color that is used to emphasize swapped characters, arrows below them and wrong letter cases, settable.
    /// - Note: When you set a new color to this property, it also updates the display.
    public var warningColor: UIColor = .orange {
        didSet { updateDisplay() }
    }
    
    /// The color that is used to display extra characters and strikethrough lines, settable.
    /// - Note: When you set a new color to this property, it also updates the display.
    public var wrongColor: UIColor = .red {
        didSet { updateDisplay() }
    }
    
    /// The color that is used to display missing characters, settable.
    /// - Note: When you set a new color to this property, it also updates the display.
    public var missingColor: UIColor = .lightGray {
        didSet { updateDisplay() }
    }
    
    /// The height needed to display the text of this view.
    public var computedContentHeight: CGFloat {
        return fontSize * 3
    }
    
    /// The size for the monospaced font that is used for displaying text.
    private let fontSize: CGFloat
    
    
    // MARK: - Display Methods
    
    /// Updates a text that is currently displayed in the labels.
    private func updateDisplayedText(with newText: THText) -> Void {
        
        let upperMutableString = NSMutableAttributedString()
        let centerMutableString = NSMutableAttributedString()
        let lowerMutableString = NSMutableAttributedString()
        
        if newText.isCompletelyCorrect {
            let correctText = newText.rawValue.toNSAttributedString
                .applying(font: .monospacedSystemFont(ofSize: fontSize, weight: .regular))
                .applying(foregroundColor: completelyCorrectColor)
            centerMutableString.append(correctText)
        } else {
            let space = " ".toNSAttributedString.applying(font: .monospacedSystemFont(ofSize: fontSize, weight: .regular))
            for char in newText {
                let currentChar = char.rawValue.toNSAttributedString.applying(font: .monospacedSystemFont(ofSize: fontSize, weight: .regular))
                switch char.type {
                    
                case .correct:
                    var correctChar = currentChar.applying(foregroundColor: correctColor)
                    if let letterCaseIsCorrect = char.hasCorrectLetterCase, letterCaseIsCorrect == false {
                        correctChar = correctChar.applying(underline: .single, withColor: warningColor)
                    }
                    upperMutableString.append(space)
                    centerMutableString.append(correctChar)
                    lowerMutableString.append(space)
                    
                case .swapped(let position):
                    let arrowSymbol: String
                    switch position {
                    case .left:  arrowSymbol = "←"
                    case .right: arrowSymbol = "→"
                    }
                    let swappedChar: NSAttributedString
                    if char.rawValue == " " {
                        swappedChar = currentChar
                            .applying(underline: .single, withColor: warningColor)
                    } else {
                        swappedChar = currentChar
                            .applying(foregroundColor: warningColor)
                    }
                    let arrow = arrowSymbol.toNSAttributedString
                        .applying(font: .monospacedSystemFont(ofSize: fontSize, weight: .regular))
                        .applying(foregroundColor: warningColor)
                    upperMutableString.append(space)
                    centerMutableString.append(swappedChar)
                    lowerMutableString.append(arrow)
                    
                case .missing:
                    let missingChar: NSAttributedString
                    if char.rawValue == " " {
                        missingChar = currentChar
                            .applying(backgroundColor: missingColor)
                            .applying(underline: .single, withColor: wrongColor)
                    } else {
                        missingChar = currentChar
                            .applying(foregroundColor: missingColor)
                            .applying(underline: .single, withColor: wrongColor)
                    }
                    upperMutableString.append(space)
                    centerMutableString.append(missingChar)
                    lowerMutableString.append(space)
                    
                case .extra:
                    let extraChar: NSAttributedString
                    if char.rawValue == " " {
                        extraChar = currentChar
                            .applying(underline: .single, withColor: wrongColor)
                    } else {
                        extraChar = currentChar
                            .applying(foregroundColor: correctColor)
                            .applying(strikethrough: 1, withColor: wrongColor)
                    }
                    upperMutableString.append(space)
                    centerMutableString.append(extraChar)
                    lowerMutableString.append(space)
                    
                case .misspell(let correctSymbol):
                    let misspellChar: NSAttributedString
                    let correctChar: NSAttributedString
                    if char.rawValue == " " {
                        misspellChar = currentChar
                            .applying(backgroundColor: missingColor)
                            .applying(underline: .single, withColor: wrongColor)
                    } else {
                        misspellChar = currentChar
                            .applying(foregroundColor: correctColor)
                            .applying(strikethrough: 1, withColor: wrongColor)
                    }
                    if correctSymbol == " " {
                        correctChar = currentChar
                            .applying(underline: .single, withColor: wrongColor)
                    } else {
                        correctChar = correctSymbol.toNSAttributedString
                            .applying(foregroundColor: wrongColor)
                    }
                    upperMutableString.append(correctChar)
                    centerMutableString.append(misspellChar)
                    lowerMutableString.append(space)
                }
                
            }
        }
        upperLabel.attributedText = upperMutableString
        textLabel.attributedText = centerMutableString
        lowerLabel.attributedText = lowerMutableString
    }
    
    
    private func updateDisplay() -> Void {
        updateDisplayedText(with: text)
    }
    
    
    // MARK: Other Methods
    
    override open func layoutSubviews() -> Void {
        super.layoutSubviews()
        updateTextAlignment()
    }
    
    private func updateTextAlignment() -> Void {
        if alignsTextToCenterIfFits, textLabel.frame.width < frame.width {
            upperLabel.textAlignment = .center
            textLabel .textAlignment = .center
            lowerLabel.textAlignment = .center
        } else {
            upperLabel.textAlignment = .left
            textLabel .textAlignment = .left
            lowerLabel.textAlignment = .left
        }
    }
    
    
    // MARK: - Init
    
    /// Creates a text view with zero frame and the specified font size.
    /// - Parameter fontSize: The size (in points) for the monospaced font that is used for displaying text.
    public convenience init(fontSize: CGFloat = 16.0) {
        self.init(frame: .zero, fontSize: fontSize)
    }
    
    /// Creates a text view with the specified frame rectangle and font size.
    /// - Parameter frame: The frame rectangle for the view, measured in points.
    /// - Parameter fontSize: The size (in points) for the monospaced font that is used for displaying text.
    public init(frame: CGRect, fontSize: CGFloat = 16.0) {
        self.fontSize = fontSize
        super.init(frame: frame)
        addSubviews()
        setupLabels()
        setupLayout()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup Methods
    
    private func setupLabels() -> Void {
        for label in [upperLabel, textLabel, lowerLabel] {
            label.backgroundColor = .clear
            label.font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        }
    }
    
    private func addSubviews() -> Void {
        addSubview(upperLabel)
        addSubview(textLabel)
        addSubview(lowerLabel)
    }
    
    
    // MARK: Layout
    
    private func setupLayout() -> Void {
        applyConstraintsToUpperLabel()
        applyConstraintsToTextLabel()
        applyConstraintsToLowerLabel()
    }
    
    private func applyConstraintsToUpperLabel() -> Void {
        upperLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            upperLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            upperLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            upperLabel.bottomAnchor.constraint(equalTo: textLabel.topAnchor),
            upperLabel.heightAnchor.constraint(equalToConstant: fontSize),
            upperLabel.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 1)
        ])
    }
    
    private func applyConstraintsToTextLabel() -> Void {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.heightAnchor.constraint(equalToConstant: fontSize),
            textLabel.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 1),
        ])
    }
    
    private func applyConstraintsToLowerLabel() -> Void {
        lowerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lowerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            lowerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            lowerLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor),
            lowerLabel.heightAnchor.constraint(equalToConstant: fontSize),
            lowerLabel.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 1),
        ])
    }
    
}


#endif
