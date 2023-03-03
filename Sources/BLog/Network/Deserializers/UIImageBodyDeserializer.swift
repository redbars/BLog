
import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

extension BLog.Network {
    struct UIImageBodyDeserializer: BLogBodyDeserializerProtocol {
#if os(iOS) || os(tvOS) || os(watchOS)
        private typealias Image = UIImage
#elseif os(OSX)
        private typealias Image = NSImage
#endif
        
        func deserialize(body: Data) -> String? {
            return Image(data: body).map { "image = [ \(Int($0.size.width)) x \(Int($0.size.height)) ]" }
        }
    }
}
