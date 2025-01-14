enum LogLevel {
    case debug, info, warning, error
}

protocol Logging {
    func log(_ message: String, level: LogLevel)
}

struct Logger: Logging {
    func log(_ message: String, level: LogLevel) {
        #if DEBUG
        print("[\(level)]: \(message)")
        #endif
    }
} 