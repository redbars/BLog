
import Foundation

public extension BLog {
    static func showEnvironment() {
        var log = "\n"
        for (key, value) in ProcessInfo.processInfo.environment {
            log += "    \(key) : \(value)\n"
        }
        
        if let udPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last {
            log += "    \("UserDefaults".uppercased()) : \(udPath)\n"
        }
        
        if writeLogToFile, let logFilesPath = BLog.logFilesPath {
            log += "    LOG FILES : \(logFilesPath)\n"
        }
        
        BLog.log(log,
                 title: "Environment",
                 separated: true)
    }
}
