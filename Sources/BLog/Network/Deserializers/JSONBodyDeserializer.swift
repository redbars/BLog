
import Foundation

extension BLog.Network {
    struct JSONBodyDeserializer: BLogBodyDeserializerProtocol {
        func deserialize(body: Data) -> String? {
            do {
                let obj = try JSONSerialization.jsonObject(with: body, options: [])
                var options: JSONSerialization.WritingOptions = [.prettyPrinted]
                
#if os(iOS) || os(tvOS) || os(watchOS)
                if #available(iOS 13.0, *) {
                    options = [.withoutEscapingSlashes, .prettyPrinted]
                }
#elseif os(OSX)
                if #available(OSX 10.15, *) {
                    options = [.withoutEscapingSlashes, .prettyPrinted]
                }
#endif
                
                let data = try JSONSerialization.data(withJSONObject: obj, options: options)
                
                return String(data: data, encoding: .utf8)
            } catch {
                return  nil
            }
        }
    }
}
