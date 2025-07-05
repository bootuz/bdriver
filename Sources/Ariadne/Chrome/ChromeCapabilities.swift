import WebDriver

public class ChromeCapabilities: BrowserCapabilities {
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
}
