#if canImport(UIKit)
import UIKit

/// The view that can display a text containing typos, such as missing, misspell or extra characters.
///
///     finder.findTypos(
///         in: "Hola", relyingOn: "Hello",
///         andHandleResult: { text in
///             textView.text = text
///         }
///     )
///
@available(iOS 13.0, *)
open class THTextView: UIScrollView {
    
    // MARK: - Properties
    
    /// The text that is currently displayed, settable.
    public var text = THText() {
        didSet {
           updateDisplayedText(with: text)
        }
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
    public var completelyCorrectColor: UIColor = .green
    
    /// The color that is used to display correct characters, settable.
    public var correctColor: UIColor = .black
    
    /// The color that is used to emphasize swapped characters, arrows below them and wrong letter cases, settable.
    public var warningColor: UIColor = .yellow
    
    /// The color that is used to display extra characters and strikethrough lines, settable.
    public var wrongColor: UIColor = .red
    
    /// The color that is used to display missing characters, settable.
    public var missingColor: UIColor = .lightGray
    
    /// The size for the monospaced font that is used for displaying text.
    private let fontSize: CGFloat
    
    
    // MARK: - Methods
    
    /// Updates a displayed text by replacing the current text with the given one.
    ///
    /// You usually don't call this method directly, instead you set a new text to the corresponding `text` property:
    ///
    ///     textView.text = newText
    ///
    public final func updateDisplayedText(with newText: THText) -> Void {
        let upperMutableString = NSMutableAttributedString()
        let centerMutableString = NSMutableAttributedString()
        let lowerMutableString = NSMutableAttributedString()
        let space = " ".toNSAttributedString.applying(font: .monospacedSystemFont(ofSize: fontSize, weight: .regular))
        for char in newText {
            let currentChar = char.rawValue.toNSAttributedString.applying(font: .monospacedSystemFont(ofSize: fontSize, weight: .regular))
            switch char.type {
            case .correct:
                let correctChar = currentChar.applying(foregroundColor: correctColor)
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
                let arrow = arrowSymbol.toNSAttributedString.applying(foregroundColor: warningColor)
                upperMutableString.append(space)
                centerMutableString.append(swappedChar)
                lowerMutableString.append(arrow)
            case .missing:
                let missingChar: NSAttributedString
                if char.rawValue == " " {
                    missingChar = currentChar
                        .applying(underline: .single, withColor: missingColor)
                } else {
                    missingChar = currentChar
                        .applying(foregroundColor: missingColor)
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
        upperLabel.attributedText = upperMutableString
        textLabel.attributedText = centerMutableString
        lowerLabel.attributedText = lowerMutableString
    }
    
    
    // MARK: - Init
    
    /// Creates a text view with the specified frame rectangle.
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
            upperLabel.bottomAnchor.constraint(equalTo: textLabel.topAnchor),
            upperLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            upperLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func applyConstraintsToTextLabel() -> Void {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func applyConstraintsToLowerLabel() -> Void {
        lowerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lowerLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor),
            lowerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            lowerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
}


#endif
