
import Foundation

public extension BLog {
    static func log(_ value: Any,
                    title: String? = nil,
                    separated: Bool = true,
                    file: String? = #file,
                    function: String? = #function,
                    line: Int? = #line) {
        guard BLog.enable else { return }
        
        var logString: String = ""
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
        
        if showInConsole {
            DispatchQueue.global(qos: .background).async {
                Swift.print(logString)
            }
        }
        
        if writeLogToFile {
            DispatchQueue.global(qos: .background).async {
                BLog.writeToFile(logString)
            }
        }
    }
}
