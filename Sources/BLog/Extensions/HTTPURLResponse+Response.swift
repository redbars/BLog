
import Foundation

extension HTTPURLResponse {
    enum Result<String>{
        case success
        case failure(BLog.LogError)
    }
    
    var status: Result<String> {
        switch self.statusCode {
        case 200...299:
            return .success
            
        default:
            let description = HTTPURLResponse.localizedString(forStatusCode: self.statusCode)
            
            let error = BLog.LogError(key: "HTTPURLResponse",
                                      value: description)
            return .failure(error)
        }
    }
}
