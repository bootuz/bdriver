import WebDriver

open class BrowserCapabilities: BaseCapabilities {
    public var browserName: BrowserName?
    public var browserVersion: String?
    public var acceptInsecureCerts: Bool?
    public var pageLoadStrategy: PageLoadStrategy?
    public var proxy: ProxyConfiguration?
    public var windowTypes: [String]?
    public var strictFileInteractability: Bool?
    public var unhandledPromptBehavior: UnhandledPromptBehavior?
    

    public override init() {
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        browserName = try container.decodeIfPresent(BrowserName.self, forKey: .browserName)
        browserVersion = try container.decodeIfPresent(String.self, forKey: .browserVersion)
        acceptInsecureCerts = try container.decodeIfPresent(Bool.self, forKey: .acceptInsecureCerts)
        pageLoadStrategy = try container.decodeIfPresent(PageLoadStrategy.self, forKey: .pageLoadStrategy)
        proxy = try container.decodeIfPresent(ProxyConfiguration.self, forKey: .proxy)
        windowTypes = try container.decodeIfPresent([String].self, forKey: .windowTypes)
        strictFileInteractability = try container.decodeIfPresent(Bool.self, forKey: .strictFileInteractability)
        unhandledPromptBehavior = try container.decodeIfPresent(UnhandledPromptBehavior.self, forKey: .unhandledPromptBehavior)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(browserName, forKey: .browserName)
        try container.encodeIfPresent(browserVersion, forKey: .browserVersion)
        try container.encodeIfPresent(acceptInsecureCerts, forKey: .acceptInsecureCerts)
        try container.encodeIfPresent(pageLoadStrategy, forKey: .pageLoadStrategy)
        try container.encodeIfPresent(proxy, forKey: .proxy)
        try container.encodeIfPresent(windowTypes, forKey: .windowTypes)
        try container.encodeIfPresent(strictFileInteractability, forKey: .strictFileInteractability)
        try container.encodeIfPresent(unhandledPromptBehavior, forKey: .unhandledPromptBehavior)
    }

    private enum CodingKeys: String, CodingKey {
        case browserName
        case browserVersion
        case acceptInsecureCerts
        case pageLoadStrategy
        case proxy
        case windowTypes
        case strictFileInteractability
        case unhandledPromptBehavior
    }

    public enum PageLoadStrategy: String, Codable {
        case normal
        case eager
        case none
    }

    public enum BrowserName: String, Codable {
        case chrome
        case firefox
        case internetExplorer = "internet explorer"
        case safari
        case opera
        case android
        case iPad
        case iPhone
        case htmlunit
    }

    public enum UnhandledPromptBehavior: String, Codable {
        case dismiss
        case accept
        case dismissAndNotify = "dismiss and notify"
        case acceptAndNotify = "accept and notify"
        case ignore
    }

    public struct ProxyConfiguration: Codable {
        public var proxyType: ProxyType
        public var proxyAutoconfigUrl: String?
        public var ftpProxy: String?
        public var httpProxy: String?
        public var noProxy: [String]?
        public var sslProxy: String?
        public var socksProxy: String?
        public var socksVersion: Int?

        public enum ProxyType: String, Codable {
            case direct
            case manual
            case pac
            case autodetect
            case system
        }
    }
}
