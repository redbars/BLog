
import Foundation

extension BLog.Network {
    struct HTMLBodyDeserializer: BLogBodyDeserializerProtocol {
        func deserialize(body: Data) -> String? {
            do {
                let attr = try NSAttributedString(
                    data: body,
                    options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html,
                              NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
                             ],
                    documentAttributes: nil)
                return attr.string
            } catch {
                return nil
            }
        }
    }
}
