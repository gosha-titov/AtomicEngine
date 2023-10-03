import Foundation

internal extension Character {
    
    /// A NSAttributedString value converted from this character value.
    ///
    ///     let attributedString = Character("a").toNSAttributedString
    ///
    var toNSAttributedString: NSAttributedString {
        return NSAttributedString(string: String(self))
    }
    
}
