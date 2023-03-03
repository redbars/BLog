
import Foundation

extension BLog {
    static var logFilesPath: URL? {
        let fm = FileManager.default
        let logPath = fm.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("logs")
        
        return logPath
    }
    
    static func writeToFile(_ string: String) {
        guard var logFilePath = logFilesPath else { return }
        
        if FileManager.default.fileExists(atPath: logFilePath.path) == false {
            do {
                try FileManager.default.createDirectory(at: logFilePath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let fileName: String = Date().formatted("dd-MM-yyyy") + ".txt"
        logFilePath.appendPathComponent(fileName)
        
        if let handle = try? FileHandle(forWritingTo: logFilePath) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: logFilePath)
        }
    }
}

public extension BLog {
    static func clearLogFiles() {
        func clear() {
            let fileManager = FileManager.default
            guard let documentsURL = logFilesPath else { return }
            
            let lastDays = BLog.daysLogToFile
            
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.contentModificationDateKey])
                let txtFiles = fileURLs.filter{$0.pathExtension == "txt"}
                
                let dates: [Date: String] = {
                    var d: [Date: String] = [:]
                    
                    txtFiles.forEach { url in
                        let fullName = url.lastPathComponent
                        let strDate = url.deletingPathExtension().lastPathComponent
                        
                        if let date = Date.toDate(strDate: strDate) {
                            d[date] = fullName
                        }
                    }
                    
                    return d
                }()
                
                let datesArr = dates.sorted { $0.value > $1.value }
                
                if datesArr.count > lastDays {
                    let deletedDatesArr = datesArr.suffix(datesArr.count - lastDays)
                    
                    try deletedDatesArr.forEach { (key: Date, value: String) in
                        try fileManager.removeItem(at: documentsURL.appendingPathComponent(value))
                    }
                }
                
                let zipFiles = fileURLs.filter{$0.pathExtension == "zip"}
                
                try zipFiles.forEach { url in
                    try fileManager.removeItem(at: url)
                }
                
            } catch {
                print("Error files \(documentsURL.path): \(error.localizedDescription)")
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            clear()
        }
    }
}

public extension BLog {
    private static func zip(itemAtURL itemURL: URL, in destinationFolderURL: URL, zipName: String) throws -> URL? {
        var error: NSError?
        var internalError: NSError?
        let finalUrl = destinationFolderURL.appendingPathComponent(zipName).appendingPathExtension("zip")
        
        NSFileCoordinator().coordinate(readingItemAt: itemURL, options: [.forUploading], error: &error) { (zipUrl) in
            do {
                try FileManager.default.moveItem(at: zipUrl, to: finalUrl)
            } catch let localError {
                internalError = localError as NSError
            }
        }
        
        if let error = error {
            throw error
        } else if let internalError = internalError {
            throw internalError
        }
        
        return finalUrl
    }
    
    static func getZipLogs() -> URL? {
        guard let logFilesPath = logFilesPath else { return nil }
        
        return try? zip(itemAtURL: logFilesPath, in: logFilesPath, zipName: "logs")
    }
}

public extension BLog {
    static func getLogFiles() -> [URL] {
        let fileManager = FileManager.default
        guard let documentsURL = logFilesPath else { return [] }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL,
                                                               includingPropertiesForKeys: [.creationDateKey])
            let txtFiles = fileURLs.filter{ $0.pathExtension == "txt" }
            
            return txtFiles
        }
        catch {
            print("Error files \(documentsURL.path): \(error.localizedDescription)")
        }
        
        return []
    }
}
