@preconcurrency import WebDriver
import Foundation

/// ChromeDriver implementation that provides Chrome browser automation
public class ChromeDriver {
    public static let defaultIp = "localhost"
    public static let defaultPort = 9515
    #if os(Windows)
    public static let executableName = "chromedriver.exe"
    #else
    public static let executableName = "chromedriver"
    #endif

    public static let defaultExecutablePath: String = "usr/local/bin/chromedriver"
    public static let defaultStartWaitTime: TimeInterval = 5.0

    private let session: Session
    private let driverService: DriverService?

    /// Initialize a ChromeDriver with service and capabilities
    /// - Parameters:
    ///   - service: Optional driver service to manage the ChromeDriver process
    ///   - capabilities: Chrome capabilities for the browser session
    ///   - start: Whether to start the driver service immediately
    public init(service: DriverService? = nil, capabilities: ChromeCapabilities = ChromeCapabilities.standard(), start: Bool = true) throws {
        let driverService = service ?? ChromeDriverService.defaultService()
        self.driverService = driverService
        
        if start {
            try driverService.start()
            
            // Wait for service to be ready
            try Self.waitForService(driverService, timeout: Self.defaultStartWaitTime)
        }
        
        // Create WebDriver and Session
        let webDriver = HTTPWebDriver(endpoint: driverService.serviceURL, wireProtocol: .w3c)
        self.session = try Session(webDriver: webDriver, capabilities: capabilities)
    }

    /// Initialize with existing WebDriver (for attach scenarios)
    /// - Parameters:
    ///   - webDriver: Existing WebDriver instance
    ///   - capabilities: Chrome capabilities for the browser session
    private init(webDriver: WebDriver, capabilities: ChromeCapabilities) throws {
        self.session = try Session(webDriver: webDriver, capabilities: capabilities)
        self.driverService = nil
    }

    /// Send a request to the ChromeDriver
    /// - Parameter request: The request to send
    /// - Returns: The response from the request
    @discardableResult
    public func send<Req: Request>(_ request: Req) throws -> Req.Response {
        try session.webDriver.send(request)
    }

    /// Attach to an already running ChromeDriver instance
    /// - Parameters:
    ///   - ip: The IP address of the ChromeDriver
    ///   - port: The port of the ChromeDriver
    ///   - capabilities: Chrome capabilities for the browser session
    /// - Returns: A new ChromeDriver instance
    public static func attach(ip: String = defaultIp, port: Int = defaultPort, capabilities: ChromeCapabilities = ChromeCapabilities.standard()) throws -> ChromeDriver {
        let httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!, wireProtocol: .w3c)
        return try ChromeDriver(webDriver: httpWebDriver, capabilities: capabilities)
    }

    /// Start the ChromeDriver service
    public func start() throws {
        try driverService?.start()
    }

    /// Stop the ChromeDriver service and quit the browser session
    public func quit() throws {
        try session.delete()
        driverService?.stop()
    }

    /// Stop the ChromeDriver service
    public func stop() {
        driverService?.stop()
    }

    /// Check if an error is an inconclusive interaction error
    /// - Parameter error: The error to check
    /// - Returns: Whether the error is an inconclusive interaction error
    public func isInconclusiveInteraction(error: ErrorResponse.Status) -> Bool {
        switch error {
        case .staleElementReference, .elementNotVisible, .elementIsNotSelectable, .invalidElementState:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Navigation
    
    /// Navigate to a URL
    /// - Parameter url: The URL to navigate to
    /// - Throws: WebDriver errors if navigation fails
    public func navigate(to url: URL) throws {
        try session.url(url)
    }
    
    /// Navigate to a URL string
    /// - Parameter urlString: The URL string to navigate to
    /// - Throws: WebDriver errors if navigation fails or URL is invalid
    public func navigate(to urlString: String) throws {
        guard let url = URL(string: urlString) else {
            throw AriadneError.invalidURL(urlString)
        }
        try navigate(to: url)
    }
    
    /// Go back in browser history
    /// - Throws: WebDriver errors if navigation fails
    public func back() throws {
        try session.back()
    }
    
    /// Go forward in browser history
    /// - Throws: WebDriver errors if navigation fails
    public func forward() throws {
        try session.forward()
    }
    
    /// Refresh the current page
    /// - Throws: WebDriver errors if refresh fails
    public func refresh() throws {
        try session.refresh()
    }
    
    /// Get the current page title
    /// - Returns: The page title
    /// - Throws: WebDriver errors if unable to get title
    public var title: String {
        get throws {
            try session.title
        }
    }
    
    /// Get the current URL
    /// - Returns: The current URL
    /// - Throws: WebDriver errors if unable to get URL
    public var currentURL: URL {
        get throws {
            try session.url
        }
    }
    
    // MARK: - Element Finding
    
    /// Find a single element by locator
    /// - Parameter locator: The element locator
    /// - Returns: The found element
    /// - Throws: WebDriver errors if element not found
    public func findElement(by locator: ElementLocator) throws -> Element {
        try session.findElement(locator: locator)
    }
    
    /// Find multiple elements by locator
    /// - Parameter locator: The element locator
    /// - Returns: Array of found elements
    /// - Throws: WebDriver errors if search fails
    public func findElements(by locator: ElementLocator) throws -> [Element] {
        try session.findElements(locator: locator)
    }
    
    // MARK: - Screenshots
    
    /// Take a screenshot of the current page
    /// - Returns: Screenshot data as PNG
    /// - Throws: WebDriver errors if screenshot fails
    public func screenshot() throws -> Data {
        try session.screenshot()
    }
    
    // MARK: - Window Management
    // TODO: Add window management methods in Phase 2
    
    /// Wait for the driver service to be ready
    /// - Parameters:
    ///   - service: The driver service to wait for
    ///   - timeout: Maximum time to wait
    /// - Throws: DriverError if service is not ready within timeout
    private static func waitForService(_ service: DriverService, timeout: TimeInterval) throws {
        let startTime = Date()
        var lastError: Error?

        while Date().timeIntervalSince(startTime) < timeout {
            guard service.isRunning else {
                throw DriverError.driverNotReady(nil)
            }

            // Try to connect to the service - simple synchronous check
            do {
                let _ = try Data(contentsOf: service.serviceURL)
                return // Service is ready
            } catch {
                lastError = error
            }

            Thread.sleep(forTimeInterval: 0.1)
        }

        throw DriverError.driverNotReady(lastError)
    }
}

// MARK: - AriadneError

/// Errors specific to Ariadne browser automation
public enum AriadneError: Error, LocalizedError {
    case invalidURL(String)
    case driverStartupFailed(underlying: Error)
    case sessionCreationFailed(underlying: Error)
    case elementNotFound(locator: String)
    case navigationTimeout(url: URL)
    case chromeDriverNotFound
    case invalidCapabilities(reason: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"
        case .driverStartupFailed(let error):
            return "Driver startup failed: \(error.localizedDescription)"
        case .sessionCreationFailed(let error):
            return "Session creation failed: \(error.localizedDescription)"
        case .elementNotFound(let locator):
            return "Element not found with locator: \(locator)"
        case .navigationTimeout(let url):
            return "Navigation timeout for URL: \(url)"
        case .chromeDriverNotFound:
            return "ChromeDriver executable not found"
        case .invalidCapabilities(let reason):
            return "Invalid capabilities: \(reason)"
        }
    }
}

/// ChromeDriver service implementation
public class ChromeDriverService: DefaultDriverService {
    
    /// Create a ChromeDriver service with the specified executable path and port
    /// - Parameters:
    ///   - executablePath: Path to the ChromeDriver executable
    ///   - port: Port to run the ChromeDriver on
    ///   - arguments: Additional arguments to pass to the ChromeDriver
    public override init(executablePath: String, port: Int = ChromeDriver.defaultPort, arguments: [String] = []) {
        super.init(executablePath: executablePath, port: port, arguments: arguments)
    }
    
    /// Create a default ChromeDriver service
    /// - Returns: A new ChromeDriverService instance
    public static func defaultService() -> ChromeDriverService {
        #if os(macOS)
        return ChromeDriverService(executablePath: ChromePaths.macDriverPath)
        #elseif os(Windows)
        return ChromeDriverService(executablePath: ChromePaths.windowsDriverPath)
        #elseif os(Linux)
        return ChromeDriverService(executablePath: ChromePaths.linuxDriverPath)
        #else
        return ChromeDriverService(executablePath: ChromeDriver.defaultExecutablePath)
        #endif
    }
}
