
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
        
        let bundleID = Bundle.main.bundleIdentifier!
        let logsUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs", isDirectory: true)
            .appendingPathComponent(bundleID, isDirectory: true)
        
        log += "    LOG FILES : \(logsUrl)\n"
        
//        if writeLogToFile, let logFilesPath = BLog.logFilesPath {
//            log += "    LOG FILES : \(logFilesPath)\n"
//        }
        
        BLog.log(log,
                 title: "Environment")
    }
}
