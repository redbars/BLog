
import Foundation

public extension BLog.Network {
    static var enable = false {
        willSet {
            if newValue {
                Sniffer.register()
            } else {
                Sniffer.unregister()
            }
        }
    }
    
    static var networkLogPrivateHeaders: [String]  = []
    
    static var showHeaders = false {
        willSet {
            Sniffer.showHeaders = newValue
        }
    }
    
    static var showPrivateHeaders = false {
        willSet {
            Sniffer.showPrivateHeaders = newValue
        }
    }
    
    static var showBody = false {
        willSet {
            Sniffer.showBody = newValue
        }
    }
}
