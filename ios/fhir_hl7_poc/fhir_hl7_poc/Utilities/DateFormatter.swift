 
import Foundation

struct DateFormatter {
    private static let dateOnlyFormatter: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private static let dateTimeFormatter: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private static let dateOnlyParser: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private static let utcDateTimeParser: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        
        // For date-only strings (no time component)
        if !dateString.contains("T") {
            guard let date = dateOnlyParser.date(from: dateString) else {
                print("Failed to parse date: \(dateString)")
                return ""
            }
            return dateOnlyFormatter.string(from: date)
        }
        
        // For date-time strings
        guard let date = utcDateTimeParser.date(from: dateString) else {
            print("Failed to parse datetime: \(dateString)")
            return ""
        }
        return dateOnlyFormatter.string(from: date)
    }
    
    static func formatDateTime(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        
        // For date-only strings (no time component)
        if !dateString.contains("T") {
            guard let date = dateOnlyParser.date(from: dateString) else {
                print("Failed to parse date: \(dateString)")
                return ""
            }
            return dateOnlyFormatter.string(from: date)
        }
        
        // For date-time strings
        guard let date = utcDateTimeParser.date(from: dateString) else {
            print("Failed to parse datetime: \(dateString)")
            return ""
        }
        return dateTimeFormatter.string(from: date)
    }
}
