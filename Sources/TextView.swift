#if canImport(UIKit)
import UIKit

@available(iOS 13.0, *)
open class THTextView: UIScrollView {
    
    // MARK: - Properties
    
    /// The text that is currently displayed, settable.
    public var text = THText()
    
    
    // MARK: UI views
    
    /// The label that displays correct characters for misspell ones.
    public let upperLabel = UILabel()
    
    /// The label that displays the text.
    public let textLabel = UILabel()
    
    /// The label that displays arrows for swapped characters.
    public let lowerLabel = UILabel()
    
    
    // MARK: UI attributes
    
    /// The size for the monospaced system font that is used for displaying text, settable.
    public var fontSize: CGFloat = 16.0
    
    /// The color that is used to display completely correct text, settable.
    public var completelyCorrectColor: UIColor = .green
    
    /// The color that is used to display correct characters, settable.
    public var correctColor: UIColor = .black
    
    /// The color that is used to display extra characters and strikethrough lines, settable.
    public var wrongColor: UIColor = .red
    
    /// The color that is used to display missing characters, settable.
    public var missingColor: UIColor = .lightGray
    
    /// The color that is used to display swapped characters and arrows below them, settable.
    public var swappedColor: UIColor = .yellow
    
    
    // MARK: - Init
    
    /// Creates a text view with the specified frame rectangle.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupLabels()
        setupLayout()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    
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
    
    
    // MARK: Setup Layout
    
    private func setupLayout() -> Void {
        applyConstraintsToUpperLabel()
        applyConstraintsToTextLabel()
        applyConstraintsToLowerLabel()
    }
    
    private func applyConstraintsToUpperLabel() -> Void {
        upperLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            upperLabel.topAnchor.constraint(equalTo: topAnchor),
            upperLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            upperLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func applyConstraintsToTextLabel() -> Void {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: upperLabel.bottomAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func applyConstraintsToLowerLabel() -> Void {
        lowerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lowerLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor),
            lowerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            lowerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            lowerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    
    // MARK: Other
    
    private func createEmptyLabel() -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        return label
    }
    
}


#endif
