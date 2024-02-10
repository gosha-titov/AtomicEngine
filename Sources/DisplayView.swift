#if canImport(UIKit)
import UIKit

// Implementation notes
// ====================
//
// The UIKit framework aligns a text of a label to the center but does NOT consider spaces at the end of this text.
// That is, it considers the length of this text up to the last character not a white space, and then aligns it using this length.
//
// For example, how it should be: [  _text__  ]
//              how it really is: [   _text__ ]
//
// Therefore, we need to aligns a label itself rather than its text:
//                                | [_text__] |
//

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
///         andHandleResult: { checkedText in
///             // The handling closure is always called on the main queue
///             // That is, it allows you to update your UI components here
///             textView.text = checkedText
///         }
///     )
///
@available(iOS 13.0, *)
open class LMDisplayView: UIScrollView {
    
    /// The text that is currently displayed, settable.
    /// - Note: When you set a new text to this property, it also updates the display.
    public var text = LMText() {
        didSet { updateDisplay() }
    }
    
    /// The boolean value that detemines whether the text is centered if its length fits into this display view’s bounding rectangle.
    /// - Note: When you set a new value to this property, it also updates the display.
    public var alignsTextToCenterIfFits = true {
        didSet {
            resetAlignment()
            needsUpdateAlignment = true
            setNeedsLayout()
        }
    }
    
    
    /// The label that displays correct characters for misspell ones.
    public let upperLabel = UILabel()
    
    /// The label that displays the text.
    public let textLabel = UILabel()
    
    /// The label that displays arrows for swapped characters.
    public let lowerLabel = UILabel()
    
    
    /// The color that is used to display completely correct text, settable.
    /// - Note: When you set a new color to this property, it also updates the display.
    public var completelyCorrectColor: UIColor = .systemGreen {
        didSet { updateDisplay() }
    }
    
    /// The color that is used to display correct characters, settable.
    /// - Note: When you set a new color to this property, it also updates the display.
    public var correctColor: UIColor = .label {
        didSet { updateDisplay() }
    }
    
    /// The color that is used to emphasize swapped characters, arrows below them and wrong letter cases, settable.
    /// - Note: When you set a new color to this property, it also updates the display.
    public var warningColor: UIColor = .systemYellow {
        didSet { updateDisplay() }
    }
    
    /// The color that is used to display extra characters and strikethrough lines, settable.
    /// - Note: When you set a new color to this property, it also updates the display.
    public var wrongColor: UIColor = .systemRed {
        didSet { updateDisplay() }
    }
    
    /// The color that is used to display missing characters, settable.
    /// - Note: When you set a new color to this property, it also updates the display.
    public var missingColor: UIColor = .systemGray3 {
        didSet { updateDisplay() }
    }
    
    /// The size for the monospaced font that is used for displaying text, settable.
    public var fontSize: CGFloat = 20 {
        didSet { updateDisplay() }
    }
    
    /// The weight for the monospaced font that is used for displaying text, settable.
    public var fontWeight: UIFont.Weight = .medium {
        didSet { updateDisplay() }
    }
    
    
    /// The constraints that are used to align label to the center.
    private var constraintsToCenter = [NSLayoutConstraint]()
    
    /// The constraints that are used to align label to fill this scroll view.
    private var constraintsToFill = [NSLayoutConstraint]()
    
    /// The boolean value that indicates whether the layout of labels should be updated.
    private var needsUpdateAlignment = false
    
    /// The edge inset values for the content view.
    private let padding: UIEdgeInsets
    
    /// The distance between labels.
    private let spacing: CGFloat
    
    
    // MARK: - Display Methods
    
    /// Updates a text that is currently displayed in the labels.
    private func display(_ newText: LMText) -> Void {
        
        let upperMutableString = NSMutableAttributedString()
        let centerMutableString = NSMutableAttributedString()
        let lowerMutableString = NSMutableAttributedString()
        
        let space = " ".toNSAttributedString.applying(font: .monospacedSystemFont(ofSize: fontSize, weight: fontWeight))
        
        guard newText.isEmpty == false else {
            upperLabel.attributedText = space
            textLabel.attributedText = space
            lowerLabel.attributedText = space
            return
        }
        
        if newText.isAbsolutelyRight {
            let correctText = newText.rawValue.toNSAttributedString
                .applying(font: .monospacedSystemFont(ofSize: fontSize, weight: fontWeight))
                .applying(foregroundColor: completelyCorrectColor)
            upperMutableString.append(space)
            centerMutableString.append(correctText)
            lowerMutableString.append(space)
        } else {
            for char in newText {
                let currentChar = char.rawValue.toNSAttributedString.applying(font: .monospacedSystemFont(ofSize: fontSize, weight: fontWeight))
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
                        .applying(font: .monospacedSystemFont(ofSize: fontSize, weight: fontWeight))
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
                    extraChar = currentChar
                        .applying(foregroundColor: correctColor)
                        .applying(strikethrough: 1, withColor: wrongColor)
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
                            .applying(font: .monospacedSystemFont(ofSize: fontSize, weight: fontWeight))
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
        resetAlignment()
        display(text)
        needsUpdateAlignment = true
        setNeedsLayout()
    }
    
    
    // MARK: Other Methods
    
    override open func layoutSubviews() -> Void {
        super.layoutSubviews()
        updateAlignmentIfNeeded()
    }
    
    private func updateAlignmentIfNeeded() -> Void {
        guard needsUpdateAlignment else { return }
        needsUpdateAlignment = false
        if alignsTextToCenterIfFits, textLabel.frame.width <= frame.width { // contentSize.width is 0
            NSLayoutConstraint.activate(constraintsToCenter)
            NSLayoutConstraint.deactivate(constraintsToFill)
        } else {
            NSLayoutConstraint.deactivate(constraintsToCenter)
            NSLayoutConstraint.activate(constraintsToFill)
        }
    }
    
    private func resetAlignment() -> Void {
        NSLayoutConstraint.deactivate(constraintsToCenter)
        NSLayoutConstraint.deactivate(constraintsToFill)
    }
    
    
    // MARK: - Init
    
    /// Creates a text view with the specified frame rectangle and font size.
    /// - Parameter frame: The frame rectangle for the view, measured in points.
    /// - Parameter padding: The edge inset values for the content view.
    /// - Parameter spacing: The distance between labels.
    public init(frame: CGRect, padding: UIEdgeInsets = .zero, spacing: CGFloat = 0) {
        self.padding = padding
        self.spacing = spacing
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
            label.font = .monospacedSystemFont(ofSize: fontSize, weight: fontWeight)
            label.backgroundColor = .clear
        }
    }
    
    private func addSubviews() -> Void {
        addSubview(upperLabel)
        addSubview(textLabel)
        addSubview(lowerLabel)
    }
    
    
    // MARK: Layout
    
    private func setupLayout() -> Void {
        addToggleableConstraints()
        applyConstraintsToSelf()
        applyCommonConstraintsToLabels()
        needsUpdateAlignment = true
        updateAlignmentIfNeeded()
    }
    
    private func applyConstraintsToSelf() -> Void {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: contentLayoutGuide.heightAnchor),
        ])
    }
    
    private func applyCommonConstraintsToLabels() -> Void {
        upperLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        lowerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            upperLabel.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor, constant: padding.top),
            textLabel.topAnchor.constraint(equalTo: upperLabel.bottomAnchor, constant: spacing),
            lowerLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: spacing),
            lowerLabel.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor, constant: -padding.bottom),
        ])
    }
    
    private func addToggleableConstraints() -> Void {
        for label in [upperLabel, textLabel, lowerLabel] {
            constraintsToFill.append(contentsOf: [
                label.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: padding.left),
                label.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -padding.right),
            ])
            constraintsToCenter.append(contentsOf: [
                label.centerXAnchor.constraint(equalTo: centerXAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: padding.left),
                label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -padding.right),
            ])
        }
    }
    
}


#endif
