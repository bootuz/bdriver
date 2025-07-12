import Foundation
import os.log

/// Log levels for Ariadne
public enum AriadneLogLevel: Int, CaseIterable, Comparable, Sendable {
    case trace = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case critical = 5
    
    public static func < (lhs: AriadneLogLevel, rhs: AriadneLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public var description: String {
        switch self {
        case .trace: return "TRACE"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARN"
        case .error: return "ERROR"
        case .critical: return "CRITICAL"
        }
    }
    
    public var emoji: String {
        switch self {
        case .trace: return "🔍"
        case .debug: return "🐛"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🚨"
        }
    }
}

/// Log categories for better organization
public enum AriadneLogCategory: String, CaseIterable, Sendable {
    case driver = "driver"
    case element = "element"
    case navigation = "navigation"
    case performance = "performance"
    case health = "health"
    case interaction = "interaction"
    case javascript = "javascript"
    case network = "network"
    case system = "system"
    case test = "test"
}

/// Log entry structure
public struct AriadneLogEntry: Sendable {
    public let timestamp: Date
    public let level: AriadneLogLevel
    public let category: AriadneLogCategory
    public let message: String
    public let metadata: [String: String]
    public let file: String
    public let function: String
    public let line: Int
    
    public init(
        timestamp: Date = Date(),
        level: AriadneLogLevel,
        category: AriadneLogCategory,
        message: String,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.timestamp = timestamp
        self.level = level
        self.category = category
        self.message = message
        self.metadata = metadata
        self.file = file
        self.function = function
        self.line = line
    }
    
    public var formattedMessage: String {
        let fileName = (file as NSString).lastPathComponent
        let metadataString = metadata.isEmpty ? "" : " | \(metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))"
        
        // Use ISO8601 formatter instead of formatted() for older macOS compatibility
        let formatter = ISO8601DateFormatter()
        let timestampString = formatter.string(from: timestamp)
        
        return "\(timestampString) [\(level.description)] [\(category.rawValue.uppercased())] \(message) (\(fileName):\(line))\(metadataString)"
    }
}

/// Protocol for log destinations
public protocol AriadneLogDestination: Sendable {
    func write(_ entry: AriadneLogEntry)
    func flush()
}

/// Console log destination
public struct ConsoleLogDestination: AriadneLogDestination {
    private let useEmojis: Bool
    private let colorEnabled: Bool
    
    public init(useEmojis: Bool = true, colorEnabled: Bool = true) {
        self.useEmojis = useEmojis
        self.colorEnabled = colorEnabled
    }
    
    public func write(_ entry: AriadneLogEntry) {
        let prefix = useEmojis ? "\(entry.level.emoji) " : ""
        let message = colorEnabled ? colorizeMessage(entry) : entry.formattedMessage
        print("\(prefix)\(message)")
    }
    
    public func flush() {
        fflush(stdout)
    }
    
    private func colorizeMessage(_ entry: AriadneLogEntry) -> String {
        let colorCode: String
        switch entry.level {
        case .trace, .debug:
            colorCode = "\u{001B}[0;37m" // Light gray
        case .info:
            colorCode = "\u{001B}[0;36m" // Cyan
        case .warning:
            colorCode = "\u{001B}[0;33m" // Yellow
        case .error:
            colorCode = "\u{001B}[0;31m" // Red
        case .critical:
            colorCode = "\u{001B}[1;31m" // Bold red
        }
        let resetCode = "\u{001B}[0;0m"
        
        return "\(colorCode)\(entry.formattedMessage)\(resetCode)"
    }
}

/// File log destination
public final class FileLogDestination: AriadneLogDestination {
    private let fileURL: URL
    private let fileHandle: FileHandle
    private let formatter: DateFormatter
    
    public init(fileURL: URL) throws {
        self.fileURL = fileURL
        
        // Create directory if needed
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        // Create file if it doesn't exist
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }
        
        self.fileHandle = try FileHandle(forWritingTo: fileURL)
        fileHandle.seekToEndOfFile()
        
        self.formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    public func write(_ entry: AriadneLogEntry) {
        let logLine = "\(entry.formattedMessage)\n"
        if let data = logLine.data(using: .utf8) {
            fileHandle.write(data)
        }
    }
    
    public func flush() {
        fileHandle.synchronizeFile()
    }
    
    deinit {
        fileHandle.closeFile()
    }
}

/// System log destination (using os.log)
@available(macOS 11.0, *)
public struct SystemLogDestination: AriadneLogDestination {
    private let logger: Logger
    
    public init(subsystem: String = "com.ariadne.browser-automation", category: String = "default") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }
    
    public func write(_ entry: AriadneLogEntry) {
        let message = "\(entry.message) | \(entry.metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))"
        
        switch entry.level {
        case .trace, .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        case .critical:
            logger.critical("\(message, privacy: .public)")
        }
    }
    
    public func flush() {
        // os.log handles flushing automatically
    }
}

/// Main logger class
public class AriadneLogger: @unchecked Sendable {
    public static let shared = AriadneLogger()
    
    private let queue = DispatchQueue(label: "ariadne.logger", qos: .utility)
    private var destinations: [AriadneLogDestination] = []
    private var minLevel: AriadneLogLevel = .info
    private var enabledCategories: Set<AriadneLogCategory> = Set(AriadneLogCategory.allCases)
    
    private init() {
        // Default to console logging
        destinations.append(ConsoleLogDestination())
    }
    
    /// Configure logging
    /// - Parameters:
    ///   - level: Minimum log level
    ///   - destinations: Log destinations
    ///   - categories: Enabled categories (nil for all)
    public func configure(
        level: AriadneLogLevel = .info,
        destinations: [AriadneLogDestination]? = nil,
        categories: [AriadneLogCategory]? = nil
    ) {
        queue.sync {
            self.minLevel = level
            
            if let destinations = destinations {
                self.destinations = destinations
            }
            
            if let categories = categories {
                self.enabledCategories = Set(categories)
            }
        }
    }
    
    /// Add log destination
    /// - Parameter destination: Destination to add
    public func addDestination(_ destination: AriadneLogDestination) {
        queue.async {
            self.destinations.append(destination)
        }
    }
    
    /// Log a message
    /// - Parameters:
    ///   - level: Log level
    ///   - category: Log category
    ///   - message: Message to log
    ///   - metadata: Additional metadata
    ///   - file: Source file
    ///   - function: Source function
    ///   - line: Source line
    public func log(
        level: AriadneLogLevel,
        category: AriadneLogCategory,
        message: String,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard level >= minLevel && enabledCategories.contains(category) else { return }
        
        let entry = AriadneLogEntry(
            level: level,
            category: category,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
        
        queue.async {
            for destination in self.destinations {
                destination.write(entry)
            }
        }
    }
    
    /// Flush all destinations
    public func flush() {
        queue.sync {
            for destination in destinations {
                destination.flush()
            }
        }
    }
    
    // MARK: - Convenience Methods
    
    public func trace(
        _ message: String,
        category: AriadneLogCategory = .system,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .trace, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func debug(
        _ message: String,
        category: AriadneLogCategory = .system,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .debug, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func info(
        _ message: String,
        category: AriadneLogCategory = .system,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .info, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func warning(
        _ message: String,
        category: AriadneLogCategory = .system,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .warning, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func error(
        _ message: String,
        category: AriadneLogCategory = .system,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .error, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func critical(
        _ message: String,
        category: AriadneLogCategory = .system,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .critical, category: category, message: message, metadata: metadata, file: file, function: function, line: line)
    }
}

/// Global logging functions for convenience
public func ariadneLog(
    level: AriadneLogLevel,
    category: AriadneLogCategory = .system,
    _ message: String,
    metadata: [String: String] = [:],
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AriadneLogger.shared.log(
        level: level,
        category: category,
        message: message,
        metadata: metadata,
        file: file,
        function: function,
        line: line
    )
}

public func ariadneTrace(
    _ message: String,
    category: AriadneLogCategory = .system,
    metadata: [String: String] = [:],
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AriadneLogger.shared.trace(message, category: category, metadata: metadata, file: file, function: function, line: line)
}

public func ariadneDebug(
    _ message: String,
    category: AriadneLogCategory = .system,
    metadata: [String: String] = [:],
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AriadneLogger.shared.debug(message, category: category, metadata: metadata, file: file, function: function, line: line)
}

public func ariadneInfo(
    _ message: String,
    category: AriadneLogCategory = .system,
    metadata: [String: String] = [:],
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AriadneLogger.shared.info(message, category: category, metadata: metadata, file: file, function: function, line: line)
}

public func ariadneWarning(
    _ message: String,
    category: AriadneLogCategory = .system,
    metadata: [String: String] = [:],
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AriadneLogger.shared.warning(message, category: category, metadata: metadata, file: file, function: function, line: line)
}

public func ariadneError(
    _ message: String,
    category: AriadneLogCategory = .system,
    metadata: [String: String] = [:],
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AriadneLogger.shared.error(message, category: category, metadata: metadata, file: file, function: function, line: line)
}

public func ariadneCritical(
    _ message: String,
    category: AriadneLogCategory = .system,
    metadata: [String: String] = [:],
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    AriadneLogger.shared.critical(message, category: category, metadata: metadata, file: file, function: function, line: line)
}

/// Extension to ChromeDriver for integrated logging
public extension ChromeDriver {
    
    /// Execute operation with automatic logging
    /// - Parameters:
    ///   - operation: Operation description
    ///   - category: Log category
    ///   - block: Operation to execute
    /// - Returns: Operation result
    /// - Throws: Any error thrown by the operation
    func withLogging<T>(
        operation: String,
        category: AriadneLogCategory = .driver,
        _ block: () throws -> T
    ) throws -> T {
        ariadneDebug("Starting: \(operation)", category: category)
        
        let startTime = Date()
        do {
            let result = try block()
            let duration = Date().timeIntervalSince(startTime)
            ariadneInfo("Completed: \(operation)", category: category, metadata: [
                "duration": String(format: "%.3f", duration)
            ])
            return result
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            ariadneError("Failed: \(operation) - \(error.localizedDescription)", category: category, metadata: [
                "duration": String(format: "%.3f", duration),
                "error": "\(error)"
            ])
            throw error
        }
    }
}
