
import Foundation

extension BLog {
    struct LogError: Error {
        var key: String
        var value: String
        
        init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }
}
