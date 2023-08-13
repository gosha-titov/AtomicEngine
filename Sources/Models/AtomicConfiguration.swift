public struct AtomicConfiguration {
    
    
    
}


extension AtomicConfiguration {
    
    public enum CharQuantity {
        
        /// A default quantity associated with 100% of chars, that is, the coefficient is `1.0`.
        case all
        
        /// A default quantity associated with 75% of chars, that is, the coefficient is `0.75`.
        case high
        
        /// A default quantity associated with 50% of chars, that is, the coefficient is `0.5`.
        case half
        
        /// A default quantity associated with 25% of chars, that is, the coefficient is `0.25`.
        case low
        
        /// A default quantity associated with 0% of chars, that is, the coefficient is `0.0`.
        case zero
        
        /// A quantity associated with a certain percentage of chars.
        case other(Double)
        
        /// A double value associated with this quantity.
        internal var coefficient: Double {
            switch self {
            case .other(let value): return value.clamped(to: 0...1.0)
            case .all:  return 1.0
            case .high: return 0.75
            case .half: return 0.5
            case .low:  return 0.25
            case .zero: return 0.0
            }
        }
        
        /// Calculates `Int` value for the given length.
        internal func calculate(for length: Int) -> Int {
            return (length.toDouble * coefficient).rounded().toInt
        }
        
    }
    
}
