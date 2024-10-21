import Foundation

/// A helper that is used for testing.
internal final class ExecutionTime {
    
    /// Measures the code execution time in seconds.
    ///
    ///     ExecutionTime.measure(title: "Sum") {
    ///         var sum = 0
    ///         10_000.times { sum += $0 }
    ///     }
    ///     //Prints "The code execution for 'Sum' took 0.1153679417 seconds."
    ///
    ///     let measuredTime = ExecutionTime.measure(printed: false) {
    ///         var sum = 0
    ///         100_000.times { sum += $0 }
    ///     } // 1.1435329914093018
    ///
    /// - Returns: The measured time in seconds spent on code execution.
    @discardableResult
    internal static func measure(title: String? = nil, printed shouldPrintResult: Bool = true, execute: () -> Void) -> CFTimeInterval {
        
        let startTime = CFAbsoluteTimeGetCurrent()
        execute()
        let endTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = endTime - startTime
        
        if shouldPrintResult {
            let titleOrEmpty = title.isNilOrEmpty ? "" : "for '" + title! + "' "
            print("The code execution \(titleOrEmpty)took \(elapsedTime) seconds.")
        }
        
        return elapsedTime
    }
    
}
