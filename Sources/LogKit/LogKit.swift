import Foundation
import OSLog

public final class Log {
    public enum Severity {
        case error, warn, info, debug
    }
    
    private static var timestampFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm:ss.SSSS"
        return formatter
    }
    
    public static var onMessage: ((Severity, String) -> Void)?

    public static func error(_ msg: String, file: String = #file, line: Int = #line) {
        logMessage(msg, severity: .error, file: file, line: line)
    }

    public static func warn(_ msg: String, file: String = #file, line: Int = #line) {
        logMessage(msg, severity: .warn, file: file, line: line)
    }

    public static func info(_ msg: String, file: String = #file, line: Int = #line) {
        logMessage(msg, severity: .info, file: file, line: line)
    }

    public static func debug(_ msg: String, file: String = #file, line: Int = #line) {
        logMessage(msg, severity: .debug, file: file, line: line)
    }

    private static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    private static var structuredLoggingSupported: Bool {
        if #available(iOS 17, *) {
            return true
        }
        return false
    }

    private static func logMessage(_ msg: String, severity: Severity, file: String, line: Int) {
        let source = file.components(separatedBy: "/").last ?? ""
        let category = String(source.prefix(upTo: source.lastIndex(of: ".") ?? source.endIndex))

        if isPreview || !structuredLoggingSupported {
            let now = Date()
            let timestamp = timestampFormatter.string(from: now)
            print("\(timestamp) | \(severity.symbol)[\(source):\(line)] \(msg)")
            return
        }

        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: category)
        logger.log(level: severity.osLogType, "[\(source):\(line)] \(msg)")
        onMessage?(severity, "[\(source):\(line)] \(msg)")
    }

    private init() {}
}

private extension Log.Severity {
    var symbol: String {
        switch self {
        case .error: "❗️"
        case .warn: "⚠️"
        case .info: ""
        case .debug: ""
        }
    }
    var osLogType: OSLogType {
        switch self {
        case .error: return .fault
        case .warn: return .error
        case .info: return .info
        case .debug: return .debug
        }
    }
}
