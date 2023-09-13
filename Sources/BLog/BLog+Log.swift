
import Foundation

public extension BLog {
    enum Level {
        case notice
        case info
        case debug
        case trace
        case warning
        case error
        case fault
        case critical
    }
    
    static func log(_ value: Any,
                    title: String? = nil,
                    level: Level = .info,
                    file: String? = #file,
                    function: String? = #function,
                    line: Int? = #line) {
        guard BLog.enable else { return }
        
        var logString: String = ""
        
        var categoryName: String = ""
        
        if let title {
            categoryName = title
        }
        
        if #available(iOS 14.0, *) {
            func middle() {
                var needSpace: Bool = false
                
                if let function = function {
                    let functionName = function
                    logString += functionName + ", "
                    needSpace = true
                }
                
                if let file = file {
                    let fileName = file.split(separator: "/").last ?? ""
                    logString += "in " + fileName + ", "
                    needSpace = true
                }
                
                if let line = line {
                    let lineName = String(describing: line)
                    logString += "at line: " + lineName + " do:"
                    needSpace = true
                }
                
                if needSpace {
                    logString += "\n"
                }
                
                if showTread {
                    let threadName = Thread.isMainThread ? String(Thread.main.description) : String(Thread.current.description)
                    logString += "thread: " + threadName
                    logString += "\n"
                }
                
                logString += Swift.String(describing: value)
            }
            
            middle()
        } else {
            let separated: Bool = true
            let time =  Date().formatted("HH:mm:ss.SSS")
            
            func header() {
                if separated {
                    logString += BLog.demitter
                    logString += "\n"
                }
            }
            
            func middle() {
                if let title = title {
                    logString += "[LOG \(title.uppercased()) \(time)]: "
                } else {
                    logString += "[LOG \(time)]: "
                }
                
                var needSpace: Bool = false
                
                if let function = function {
                    let functionName = function
                    logString += functionName + ", "
                    needSpace = true
                }
                
                if let file = file {
                    let fileName = file.split(separator: "/").last ?? ""
                    logString += "in " + fileName + ", "
                    needSpace = true
                }
                
                if let line = line {
                    let lineName = String(describing: line)
                    logString += "at line: " + lineName + " do:"
                    needSpace = true
                }
                
                if needSpace {
                    logString += "\n"
                }
                
                if showTread {
                    let threadName = Thread.isMainThread ? String(Thread.main.description) : String(Thread.current.description)
                    logString += "thread: " + threadName
                    logString += "\n"
                }
                
                logString += Swift.String(describing: value)
            }
            
            func footer() {
                if separated {
                    logString += "\n"
                    logString += BLog.demitter
                }
            }
            
            header()
            middle()
            footer()
        }
        
        if showInConsole {
            if #available(iOS 14.0, *) {
                if !Logger.loggers.contains(where: { $0.key == categoryName }) {
                    Logger.loggers[categoryName] = .init(subsystem: Logger.subsystem, category: categoryName)
                }
                
                var logger: Logger? { return Logger.loggers[categoryName] }
                
                switch level {
                case .notice:
                    logger?.notice("\(logString)")
                case .info:
                    logger?.info("\(logString)")
                case .debug:
                    logger?.debug("\(logString)")
                case .trace:
                    logger?.trace("\(logString)")
                case .warning:
                    logger?.warning("\(logString)")
                case .error:
                    logger?.error("\(logString)")
                case .fault:
                    logger?.fault("\(logString)")
                case .critical:
                    logger?.critical("\(logString)")
                }
                
            } else {
                DispatchQueue.global(qos: .background).async {
                    Swift.print(logString)
                }
                
                if writeLogToFile {
                    DispatchQueue.global(qos: .background).async {
                        BLog.writeToFile(logString)
                    }
                }
            }
        }
    }
}

import OSLog

@available(iOS 14.0, *)
extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    static var subsystem = Bundle.main.bundleIdentifier!
    
    static var loggers: [String:Logger] = [:]
}
