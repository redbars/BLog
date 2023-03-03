//	Created by boris on 22.03.2022.
//	Copyright © 2022 DIGITAL ENTERPRISE SOLUTIONS LLC. All rights reserved.

import Foundation

public protocol BFileMonitorDelegate: AnyObject {
    func didReceive(changes: String)
}

public extension BLog {
    @available(iOS 13.0, *)
    class BFileMonitor {
        let url: URL
        
        let fileHandle: FileHandle
        let source: DispatchSourceFileSystemObject
        
        public weak var delegate: BFileMonitorDelegate?
        
        public init(url: URL) throws {
            self.url = url
            self.fileHandle = try FileHandle(forReadingFrom: url)
            
            source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fileHandle.fileDescriptor,
                eventMask: .extend,
                queue: DispatchQueue.main
            )
            
            source.setEventHandler {
                let event = self.source.data
                self.process(event: event)
            }
            
            source.setCancelHandler {
                if #available(macOS 10.15, *) {
                    try? self.fileHandle.close()
                } else {
                    // Fallback on earlier versions
                }
            }
            
            fileHandle.seekToEndOfFile()
            source.resume()
        }
        
        func process(event: DispatchSource.FileSystemEvent) {
            guard event.contains(.extend) else {  return }
            
            let newData = self.fileHandle.readDataToEndOfFile()
            let string = String(data: newData, encoding: .utf8)!
            self.delegate?.didReceive(changes: string)
        }
        
        deinit {
            source.cancel()
        }
    }
}
