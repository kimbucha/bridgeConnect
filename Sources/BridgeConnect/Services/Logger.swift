import Foundation
import OSLog

public class Logger: LoggerProtocol {
    private let logger: os.Logger
    
    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.bridgeconnect",
                category: String = "default") {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }
    
    public func log(_ message: String,
                    level: LogLevel = .info,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
        let formattedMessage = "\(level.emoji) [\(level)] \(message) - \(sourceFileName(filePath: file)):\(line) \(function)"
        
        switch level {
        case .debug:
            logger.debug("\(formattedMessage)")
        case .info:
            logger.info("\(formattedMessage)")
        case .warning:
            logger.warning("\(formattedMessage)")
        case .error:
            logger.error("\(formattedMessage)")
        case .critical:
            logger.critical("\(formattedMessage)")
        }
    }
    
    private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last ?? ""
    }
} 