import WebDriver

public final class ChromeCapabilities: BrowserCapabilities, @unchecked Sendable {
    public var chromeOptions: ChromeOptions?

    public override init() {
        super.init()
        self.browserName = .chrome
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chromeOptions = try container.decodeIfPresent(ChromeOptions.self, forKey: .chromeOptions)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(chromeOptions, forKey: .chromeOptions)
    }

    private enum CodingKeys: String, CodingKey {
        case chromeOptions = "goog:chromeOptions"
    }

    public struct ChromeOptions: Codable {
        public var args: [String]?
        public var binary: String?
        public var extensions: [String]?
        public var prefs: [String: String]?
        public var detach: Bool?
        public var debuggerAddress: String?
        public var excludeSwitches: [String]?
        public var minidumpPath: String?
        public var mobileEmulation: MobileEmulation?
        public var perfLoggingPrefs: PerfLoggingPrefs?
        public var windowTypes: [String]?

        public init() {}

        // Custom encoding for the prefs dictionary which can contain various types
        private enum CodingKeys: String, CodingKey {
            case args, binary, extensions, prefs, detach, debuggerAddress
            case excludeSwitches, minidumpPath, mobileEmulation, perfLoggingPrefs, windowTypes
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(args, forKey: .args)
            try container.encodeIfPresent(binary, forKey: .binary)
            try container.encodeIfPresent(extensions, forKey: .extensions)
            try container.encodeIfPresent(detach, forKey: .detach)
            try container.encodeIfPresent(debuggerAddress, forKey: .debuggerAddress)
            try container.encodeIfPresent(excludeSwitches, forKey: .excludeSwitches)
            try container.encodeIfPresent(minidumpPath, forKey: .minidumpPath)
            try container.encodeIfPresent(mobileEmulation, forKey: .mobileEmulation)
            try container.encodeIfPresent(perfLoggingPrefs, forKey: .perfLoggingPrefs)
            try container.encodeIfPresent(windowTypes, forKey: .windowTypes)
            try container.encodeIfPresent(prefs, forKey: .prefs)
        }

        // Dynamic coding keys for the prefs dictionary
        private struct DynamicCodingKeys: CodingKey {
            var stringValue: String
            var intValue: Int?

            init(stringValue: String) {
                self.stringValue = stringValue
                self.intValue = nil
            }

            init?(intValue: Int) {
                self.stringValue = String(intValue)
                self.intValue = intValue
            }
        }

        public struct MobileEmulation: Codable {
            public var deviceName: String?
            public var deviceMetrics: DeviceMetrics?
            public var userAgent: String?

            public struct DeviceMetrics: Codable {
                public var width: Int
                public var height: Int
                public var pixelRatio: Double
                public var touch: Bool
            }
        }

        public struct PerfLoggingPrefs: Codable {
            public var enableNetwork: Bool?
            public var enablePage: Bool?
            public var traceCategories: String?
            public var bufferUsageReportingInterval: Int?
        }
    }

    // Factory methods for common configurations

    public static func standard() -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.args = ["--start-maximized"]
        return caps
    }

    public static func headless() -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.args = ["--headless", "--disable-gpu", "--window-size=1920,1080"]
        return caps
    }

    public static func withUserProfile(profilePath: String) -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.args = ["--user-data-dir=\(profilePath)"]
        return caps
    }
    
    /// Create capabilities for mobile emulation
    /// - Parameter deviceName: The device name to emulate (e.g., "iPhone 12 Pro")
    /// - Returns: ChromeCapabilities configured for mobile emulation
    public static func mobileEmulation(deviceName: String) -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.mobileEmulation = ChromeOptions.MobileEmulation()
        caps.chromeOptions?.mobileEmulation?.deviceName = deviceName
        return caps
    }
    
    /// Create capabilities for custom mobile emulation
    /// - Parameters:
    ///   - width: Screen width
    ///   - height: Screen height
    ///   - pixelRatio: Device pixel ratio
    ///   - userAgent: User agent string
    /// - Returns: ChromeCapabilities configured for custom mobile emulation
    public static func customMobileEmulation(width: Int, height: Int, pixelRatio: Double, userAgent: String) -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.mobileEmulation = ChromeOptions.MobileEmulation()
        caps.chromeOptions?.mobileEmulation?.deviceMetrics = ChromeOptions.MobileEmulation.DeviceMetrics(
            width: width,
            height: height,
            pixelRatio: pixelRatio,
            touch: true
        )
        caps.chromeOptions?.mobileEmulation?.userAgent = userAgent
        return caps
    }
    
    /// Create capabilities with performance logging enabled
    /// - Returns: ChromeCapabilities with performance logging enabled
    public static func withPerformanceLogging() -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.perfLoggingPrefs = ChromeOptions.PerfLoggingPrefs()
        caps.chromeOptions?.perfLoggingPrefs?.enableNetwork = true
        caps.chromeOptions?.perfLoggingPrefs?.enablePage = true
        caps.chromeOptions?.perfLoggingPrefs?.traceCategories = "devtools.timeline"
        return caps
    }
    
    /// Create capabilities with extensions
    /// - Parameter extensionPaths: Array of extension paths to install
    /// - Returns: ChromeCapabilities with extensions
    public static func withExtensions(extensionPaths: [String]) -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.extensions = extensionPaths
        return caps
    }
    
    /// Create capabilities with custom arguments
    /// - Parameter args: Array of Chrome arguments
    /// - Returns: ChromeCapabilities with custom arguments
    public static func withArguments(_ args: [String]) -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.args = args
        return caps
    }
    
    /// Create capabilities for debugging
    /// - Parameter debuggerAddress: The debugger address (e.g., "localhost:9222")
    /// - Returns: ChromeCapabilities configured for debugging
    public static func withDebugging(debuggerAddress: String) -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.debuggerAddress = debuggerAddress
        return caps
    }
    
    /// Create capabilities with disabled features for testing
    /// - Returns: ChromeCapabilities optimized for testing
    public static func forTesting() -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.args = [
            "--no-sandbox",
            "--disable-dev-shm-usage",
            "--disable-gpu",
            "--disable-extensions",
            "--disable-plugins",
            "--disable-images",
            "--disable-javascript",
            "--disable-default-apps",
            "--disable-background-networking",
            "--disable-sync",
            "--disable-translate",
            "--disable-web-security",
            "--disable-features=VizDisplayCompositor",
            "--headless"
        ]
        return caps
    }
    
    /// Create capabilities with custom preferences
    /// - Parameter prefs: Dictionary of Chrome preferences
    /// - Returns: ChromeCapabilities with custom preferences
    public static func withPreferences(_ prefs: [String: String]) -> ChromeCapabilities {
        let caps = ChromeCapabilities()
        caps.chromeOptions = ChromeOptions()
        caps.chromeOptions?.prefs = prefs
        return caps
    }
    
    /// Add argument to existing capabilities
    /// - Parameter argument: The argument to add
    /// - Returns: Self for method chaining
    @discardableResult
    public func addArgument(_ argument: String) -> ChromeCapabilities {
        if chromeOptions == nil {
            chromeOptions = ChromeOptions()
        }
        if chromeOptions?.args == nil {
            chromeOptions?.args = []
        }
        chromeOptions?.args?.append(argument)
        return self
    }
    
    /// Add multiple arguments to existing capabilities
    /// - Parameter arguments: The arguments to add
    /// - Returns: Self for method chaining
    @discardableResult
    public func addArguments(_ arguments: [String]) -> ChromeCapabilities {
        for argument in arguments {
            addArgument(argument)
        }
        return self
    }
    
    /// Set Chrome binary path
    /// - Parameter path: Path to Chrome binary
    /// - Returns: Self for method chaining
    @discardableResult
    public func setBinary(_ path: String) -> ChromeCapabilities {
        if chromeOptions == nil {
            chromeOptions = ChromeOptions()
        }
        chromeOptions?.binary = path
        return self
    }
    
    /// Enable detach mode
    /// - Returns: Self for method chaining
    @discardableResult
    public func enableDetach() -> ChromeCapabilities {
        if chromeOptions == nil {
            chromeOptions = ChromeOptions()
        }
        chromeOptions?.detach = true
        return self
    }
}
