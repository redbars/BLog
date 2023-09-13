
import Foundation

public extension BLog.Network {
    static func log(_ text: Any?,
                    level: BLog.Level = .info,
                    file: String? = #file,
                    function: String? = #function,
                    line: Int? = #line) {
        
        if enable {
            guard let text = text else { return }
            
            BLog.log(text,
                       title: "Network",
                        level: level,
                       file: file,
                       function: function,
                       line: line)
        }
    }
}

public extension BLog.Network {
    static func networkRequest(_ request: URLRequest?,
                               isMock: Bool = false,
                               file: String? = #file,
                               function: String? = #function,
                               line: Int? = #line) {
        var result: [String] = []
        var startlog = "⬆️"
        
        if isMock {
            startlog = startlog + " " + "❗️MOCK❗️"
        }
        
        guard let request = request else {
            result.append(startlog + " " + "URLRequest is Empty")
            let log = result.filter { !$0.isEmpty }.joined(separator: "\n")
            BLog.Network.log(log,
                             file: file,
                             function: function,
                             line: line)
            return
        }
        
        result.append(startlog + " " + "Request:")
        
        if let url = request.url?.absoluteString {
            result.append("[\(request.httpMethod!)] \(url)")
        }
        
        result.append(log(headers: request.allHTTPHeaderFields))
        result.append(log(body: request))
        
        let log = result.filter { !$0.isEmpty }.joined(separator: "\n")
        BLog.Network.log(log,
                         file: file,
                         function: function,
                         line: line)
    }
}

public extension BLog.Network {
    static func networkResponse(_ response: URLResponse?,
                                request: URLRequest? = nil,
                                data: Data? = nil,
                                isMock: Bool = false,
                                file: String? = #file,
                                function: String? = #function,
                                line: Int? = #line) {
        var result: [String] = []
        var startlog = "⬇️"
        
        if isMock {
            startlog = startlog + " " + "❗️MOCK❗️"
        }
        
        result.append(startlog + " " + "Response:")
        
        var urlResult: [String] = []
        if let response = response, let responseUrl = response.url?.absoluteString {
            urlResult.append(responseUrl)
        } else if !isMock {
            result.append("❌ URLResponse is Empty")
        }
        
        if let request = request {
            if urlResult.isEmpty, let requestUrl = request.url?.absoluteString {
                urlResult.append(requestUrl)
            }
            
            if let httpMethod = request.httpMethod {
                urlResult.insert("[\(httpMethod)]", at: 0)
            }
        }
        
        let url = urlResult.filter { !$0.isEmpty }.joined(separator: " ")
        result.append(url)
        
        var contentType = "application/octet-stream"
        
        if let httpResponse = response as? HTTPURLResponse {
            let localisedStatus = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode).capitalized
            
            switch httpResponse.status {
            case .success:
                result.append("Status: ✅ \(httpResponse.statusCode) - \(localisedStatus)")
            case .failure(_):
                result.append("Status: ❌ \(httpResponse.statusCode) - \(localisedStatus)")
            }
            
            result.append(log(headers: httpResponse.allHeaderFields as? [String: String]))
            
            if let type = httpResponse.allHeaderFields["Content-Type"] as? String {
                contentType = type
            }
        }
        
        if let urlRequest = request as URLRequest?, let startDate = Sniffer.property(forKey: Sniffer.Keys.duration, in: urlRequest) as? Date {
            let difference = fabs(startDate.timeIntervalSinceNow)
            result.append("Duration: \(difference)s")
        }
        
        guard let data = data else {
            let log = result.filter { !$0.isEmpty }.joined(separator: "\n")
            BLog.Network.log(log,
                             file: file,
                             function: function,
                             line: line)
            return
        }
        
        result.append("Body: [")
        result.append("Size \(data)")
        if Sniffer.showBody {
            if let deserialize = self.deserialize(body: data, for: contentType) ?? PlainTextBodyDeserializer().deserialize(body: data) {
                result.append(deserialize)
            }
        }
        result.append("]")
        
        let log = result.filter { !$0.isEmpty }.joined(separator: "\n")
        
        BLog.Network.log(log,
                         level: isMock ? .warning : .info,
                         file: file,
                         function: function,
                         line: line)
    }
    
    fileprivate static func log(headers: [String: String]?) -> String {
        guard let headers = headers, !headers.isEmpty, Sniffer.showHeaders else { return "" }
        
        var values: [String] = []
        values.append("Headers: [")
        values.append("Count: \(headers.count)")
        
        for (key, value) in headers {
            if !Sniffer.showPrivateHeaders && networkLogPrivateHeaders.contains(key) {
                values.append("  \(key) : P(\(value.count))")
            } else {
                values.append("  \(key) : \(value)")
            }
        }
        
        values.append("]")
        return values.joined(separator: "\n")
    }
    
    fileprivate static func log(body request: URLRequest) -> String {
        guard let body = body(from: request) else { return "" }
        
        var result: [String] = []
        result.append("Body: [")
        result.append("Size \(body)")
        if Sniffer.showBody {
            if let deserialized = deserialize(body: body, for: request.value(forHTTPHeaderField: "Content-Type") ?? "application/octet-stream") {
                result.append(deserialized)
            }
        }
        result.append("]")
        
        return result.filter { !$0.isEmpty }.joined(separator: "\n")
    }
    
    fileprivate static func body(from request: URLRequest) -> Data? {
        return request.httpBody ?? request.httpBodyStream.flatMap { stream in
            let data = NSMutableData()
            stream.open()
            while stream.hasBytesAvailable {
                var buffer = [UInt8](repeating: 0, count: 1024)
                let length = stream.read(&buffer, maxLength: buffer.count)
                data.append(buffer, length: length)
            }
            stream.close()
            return data as Data
        }
    }
    
    fileprivate static func find(deserialize contentType: String) -> BLogBodyDeserializerProtocol? {
        for (pattern, deserializer) in Sniffer.bodyDeserializers {
            do {
                let regex = try NSRegularExpression(pattern: pattern.replacingOccurrences(of: "*", with: "[a-z]+"))
                let results = regex.matches(in: contentType, range: NSRange(location: 0, length: contentType.count))
                
                if !results.isEmpty {
                    return deserializer
                }
            } catch {
                continue
            }
        }
        
        return nil
    }
    
    fileprivate static func deserialize(body: Data, `for` contentType: String) -> String? {
        return find(deserialize: contentType)?.deserialize(body: body)
    }
}
