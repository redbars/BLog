
import Foundation

extension BLog.Network {
    struct PlainTextBodyDeserializer: BLogBodyDeserializerProtocol {
        func deserialize(body: Data) -> String? {
            return String(data: body, encoding: .utf8)
        }
    }
}
