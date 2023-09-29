import Foundation

open class THTypoFinder {
    
    // MARK: - Properties
    
    /// The queue that is used for **asynchronous** execution of all finding operations which go strickly after each other.
    ///
    /// This property has the default value that is created in the following way:
    ///
    ///     var queue = DispatchQueue(
    ///         label: "com.typo-hunt.main",
    ///         qos: .userInteractive
    ///     )
    ///
    /// - Note: In the case when this property has no value (`nil`), the typo finding process is performed **asynchronously** on **the main thread**.
    public var queue: DispatchQueue? = .init(label: "com.typo-hunt.main", qos: .userInteractive)
    
    /// The configuration consisting of parameters that are used during the creation of a text.
    public var configuration = THConfiguration()
    
    
    // MARK: - Init
    
    /// Creates a typo finder instance.
    public init() {}
    
}
