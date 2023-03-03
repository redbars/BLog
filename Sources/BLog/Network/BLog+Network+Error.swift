
import Foundation

public extension BLog.Network {
    static func error(_ response: URLResponse?,
                      request: URLRequest? = nil,
                      error: [Error]?,
                      file: String? = #file,
                      function: String? = #function,
                      line: Int? = #line) {
        var result: [String] = []
        let startlog = "⬇️"
        
        result.append(startlog + " " + "❗️ERROR❗️ Response:")
        
        var urlResult: [String] = []
        if let response = response, let responseUrl = response.url?.absoluteString {
            urlResult.append(responseUrl)
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
        
        if let urlRequest = request as URLRequest?, let startDate = Sniffer.property(forKey: Sniffer.Keys.duration, in: urlRequest) as? Date {
            let difference = fabs(startDate.timeIntervalSinceNow)
            result.append("Duration: \(difference)s")
        }
        
        if error?.count ?? 0 > 0 {
            result.append("❌ Errors: [")
            error?.forEach({ (error) in
                result.append("Error: \(error)")
            })
            result.append("]")
        }
        
        let log = result.filter { !$0.isEmpty }.joined(separator: "\n")
        
        BLog.Network.log(log,
                         file: file,
                         function: function,
                         line: line)
    }
}
