
import Foundation

extension Date {
    func formatted(_ format: String = "dd/MM/yyyy HH:mm:ss ZZZ", timeZone: TimeZone? = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
}

extension Date {
    static func toDate(strDate: String, format: String = "dd-MM-yyyy") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = dateFormatter.date(from: strDate)
        
        return date
    }
}

