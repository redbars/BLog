
import Foundation

protocol BLogBodyDeserializerProtocol {
    func deserialize(body: Data) -> String?
}
