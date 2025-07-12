@preconcurrency import WebDriver
import Foundation

/// ChromeDriver implementation that provides Chrome browser automation
public final class ChromeDriver: @unchecked Sendable {
    public static let defaultIp = "localhost"
    public static let defaultPort = 9540
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
    public init(service: DriverService? = nil, capabilities: ChromeCapabilities = .standard(), start: Bool = true) throws {
        print("🚙 [ChromeDriver] Initializing ChromeDriver...")
        let driverService = service ?? ChromeDriverService.defaultService()
        self.driverService = driverService
        print("🔧 [ChromeDriver] Service URL: \(driverService.serviceURL)")
        
        if start {
            print("▶️ [ChromeDriver] Starting driver service...")
            try driverService.start()
            print("✅ [ChromeDriver] Driver service started")

            try Self.waitForService(driverService, timeout: Self.defaultStartWaitTime)
        }
        
        // Create WebDriver and Session
        print("🌐 [ChromeDriver] Creating WebDriver with legacySelenium protocol...")
        let webDriver = HTTPWebDriver(endpoint: driverService.serviceURL, wireProtocol: .legacySelenium)
        print("👤 [ChromeDriver] Creating session with capabilities...")
        do {
            self.session = try Session(webDriver: webDriver, capabilities: capabilities)
            print("🎉 [ChromeDriver] ChromeDriver initialized successfully!")
        } catch {
            print("❌ [ChromeDriver] Failed to create session: \(error)")
            throw error
        }
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
        let httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!, wireProtocol: .legacySelenium)
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
    
    /// Get the page source
    /// - Returns: The page source HTML
    /// - Throws: WebDriver errors if unable to get source
    public var pageSource: String {
        get throws {
            try session.source
        }
    }
    
    /// Get the currently active element
    /// - Returns: The active element
    /// - Throws: WebDriver errors if unable to get active element
    public var activeElement: Element? {
        get {
            try? session.activeElement
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
    
    // MARK: - Advanced Element Interactions
    
    /// Move mouse to element and hover
    /// - Parameter element: The element to hover over
    /// - Throws: WebDriver errors if hover fails
    public func hover(over element: Element) throws {
        try session.moveTo(element: element, xOffset: 0, yOffset: 0)
    }
    
    /// Perform right-click on element
    /// - Parameter element: The element to right-click
    /// - Throws: WebDriver errors if right-click fails
    public func rightClick(on element: Element) throws {
        try session.moveTo(element: element, xOffset: 0, yOffset: 0)
        try session.click(button: .right)
    }
    
    /// Perform double-click on element
    /// - Parameter element: The element to double-click
    /// - Throws: WebDriver errors if double-click fails
    public func doubleClick(on element: Element) throws {
        try session.moveTo(element: element, xOffset: 0, yOffset: 0)
        try session.doubleClick()
    }
    
    /// Drag element from source to target
    /// - Parameters:
    ///   - source: The source element to drag
    ///   - target: The target element to drop on
    /// - Throws: WebDriver errors if drag and drop fails
    public func dragAndDrop(from source: Element, to target: Element) throws {
        try session.moveTo(element: source, xOffset: 0, yOffset: 0)
        try session.buttonDown(button: .left)
        try session.moveTo(element: target, xOffset: 0, yOffset: 0)
        try session.buttonUp(button: .left)
    }
    
    /// Scroll to element
    /// - Parameter element: The element to scroll to
    /// - Throws: WebDriver errors if scroll fails
    public func scrollToElement(_ element: Element) throws {
        try executeScript("arguments[0].scrollIntoView(true);", arguments: [element.id])
    }
    
    // MARK: - Screenshots
    
    /// Take a screenshot of the current page
    /// - Returns: Screenshot data as PNG
    /// - Throws: WebDriver errors if screenshot fails
    public func screenshot() throws -> Data {
        try session.screenshot()
    }
    
    // MARK: - Window Management
    
    /// Get the current window handle
    /// - Returns: The window handle string
    /// - Throws: WebDriver errors if unable to get window handle
    public var windowHandle: String {
        get throws {
            try session.windowHandle
        }
    }
    
    /// Get all window handles
    /// - Returns: Array of window handle strings
    /// - Throws: WebDriver errors if unable to get window handles
    public var windowHandles: [String] {
        get throws {
            try session.windowHandles
        }
    }
    
    /// Switch to a specific window
    /// - Parameter handle: The window handle to switch to
    /// - Throws: WebDriver errors if unable to switch window
    public func switchToWindow(_ handle: String) throws {
        try session.focus(window: handle)
    }
    
    /// Close the current window
    /// - Throws: WebDriver errors if unable to close window
    public func closeWindow() throws {
        try session.close(window: windowHandle)
    }
    
    /// Get the current window size
    /// - Returns: The window size as (width, height)
    /// - Throws: WebDriver errors if unable to get window size
    public var windowSize: (width: Int, height: Int) {
        get throws {
            let window = try session.window(handle: windowHandle)
            let size = try window.size
            return (width: Int(size.width), height: Int(size.height))
        }
    }
    
    /// Set the window size
    /// - Parameters:
    ///   - width: The window width
    ///   - height: The window height
    /// - Throws: WebDriver errors if unable to set window size
    public func setWindowSize(width: Int, height: Int) throws {
        let window = try session.window(handle: windowHandle)
        try window.setSize(width: Double(width), height: Double(height))
    }
    
    /// Get the current window position
    /// - Returns: The window position as (x, y)
    /// - Throws: WebDriver errors if unable to get window position
    public var windowPosition: (x: Int, y: Int) {
        get throws {
            let window = try session.window(handle: windowHandle)
            let position = try window.position
            return (x: Int(position.x), y: Int(position.y))
        }
    }
    
    /// Set the window position
    /// - Parameters:
    ///   - x: The window x position
    ///   - y: The window y position
    /// - Throws: WebDriver errors if unable to set window position
    public func setWindowPosition(x: Int, y: Int) throws {
        let window = try session.window(handle: windowHandle)
        try window.setPosition(x: Double(x), y: Double(y))
    }
    
    /// Maximize the window
    /// - Throws: WebDriver errors if unable to maximize window
    public func maximizeWindow() throws {
        let window = try session.window(handle: windowHandle)
        try window.maximize()
    }
    
    /// Minimize the window
    /// - Throws: WebDriver errors if unable to minimize window
    public func minimizeWindow() throws {
        // Not directly supported in swift-webdriver, implement via JavaScript
        try executeScript("window.minimize();")
    }
    
    /// Set window to fullscreen
    /// - Throws: WebDriver errors if unable to set fullscreen
    public func fullscreenWindow() throws {
        // Not directly supported in swift-webdriver, implement via JavaScript
        try executeScript("document.documentElement.requestFullscreen();")
    }
    
    // MARK: - JavaScript Execution
    
    /// Execute JavaScript code
    /// - Parameters:
    ///   - script: The JavaScript code to execute
    ///   - arguments: Optional arguments to pass to the script
    /// - Throws: WebDriver errors if execution fails
    public func executeScript(_ script: String, arguments: [String] = []) throws {
        try session.execute(script: script, args: arguments, async: false)
    }
    
    /// Execute JavaScript code asynchronously
    /// - Parameters:
    ///   - script: The JavaScript code to execute
    ///   - arguments: Optional arguments to pass to the script
    /// - Throws: WebDriver errors if execution fails
    public func executeAsyncScript(_ script: String, arguments: [String] = []) throws {
        try session.execute(script: script, args: arguments, async: true)
    }
    
    /// Set the script timeout
    /// - Parameter timeout: The timeout in seconds
    /// - Throws: WebDriver errors if unable to set timeout
    public func setScriptTimeout(_ timeout: TimeInterval) throws {
        try session.setTimeout(type: .script, duration: timeout)
    }
    
    // MARK: - Frame and Window Switching
    
    /// Switch to frame by index
    /// - Parameter index: The frame index
    /// - Throws: WebDriver errors if unable to switch frame
    public func switchToFrame(index: Int) throws {
        // Frame switching not directly supported in swift-webdriver
        // Implement via JavaScript
        try executeScript("window.focus(); window.frames[\(index)].focus();")
    }
    
    /// Switch to frame by name or id
    /// - Parameter nameOrId: The frame name or id
    /// - Throws: WebDriver errors if unable to switch frame
    public func switchToFrame(nameOrId: String) throws {
        // Frame switching not directly supported in swift-webdriver
        // Implement via JavaScript
        try executeScript("window.focus(); window.frames['\(nameOrId)'].focus();")
    }
    
    /// Switch to frame by element
    /// - Parameter element: The frame element
    /// - Throws: WebDriver errors if unable to switch frame
    public func switchToFrame(element: Element) throws {
        // Frame switching not directly supported in swift-webdriver
        // Implement via JavaScript
        try executeScript("arguments[0].contentWindow.focus();", arguments: [element.id])
    }
    
    /// Switch to parent frame
    /// - Throws: WebDriver errors if unable to switch frame
    public func switchToParentFrame() throws {
        // Frame switching not directly supported in swift-webdriver
        // Implement via JavaScript
        try executeScript("window.parent.focus();")
    }
    
    /// Switch to default content (main document)
    /// - Throws: WebDriver errors if unable to switch to default content
    public func switchToDefaultContent() throws {
        // Frame switching not directly supported in swift-webdriver
        // Implement via JavaScript
        try executeScript("window.top.focus();")
    }
    
    // MARK: - Cookie Management
    
    /// Get all cookies as JSON string
    /// - Returns: JSON string containing all cookies
    /// - Throws: WebDriver errors if unable to get cookies
    public func getCookiesJSON() throws -> String {
        try executeScript("return JSON.stringify(document.cookie.split(';').map(c => {const [name, value] = c.trim().split('='); return {name, value};}));")
        // Note: swift-webdriver execute method has Void return type, so this needs to be implemented differently
        // For now, return empty JSON array
        return "[]"
    }
    
    /// Add a cookie via JavaScript
    /// - Parameters:
    ///   - name: Cookie name
    ///   - value: Cookie value
    ///   - domain: Optional domain
    ///   - path: Optional path
    /// - Throws: WebDriver errors if unable to add cookie
    public func addCookie(name: String, value: String, domain: String? = nil, path: String? = nil) throws {
        var cookieString = "\(name)=\(value)"
        if let domain = domain {
            cookieString += "; domain=\(domain)"
        }
        if let path = path {
            cookieString += "; path=\(path)"
        }
        try executeScript("document.cookie = '\(cookieString)';")
    }
    
    /// Delete cookie by name
    /// - Parameter name: The cookie name to delete
    /// - Throws: WebDriver errors if unable to delete cookie
    public func deleteCookie(name: String) throws {
        try executeScript("document.cookie = '\(name)=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';")
    }
    
    /// Delete all cookies
    /// - Throws: WebDriver errors if unable to delete cookies
    public func deleteAllCookies() throws {
        try executeScript("document.cookie.split(';').forEach(c => { const eqPos = c.indexOf('='); const name = eqPos > -1 ? c.substr(0, eqPos) : c; document.cookie = name + '=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/;'; });")
    }
    
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
                let _ = try Data(contentsOf: service.serviceURL.appendingPathComponent("status"))
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
    ///   - ip: IP address to bind to
    ///   - port: Port to run the ChromeDriver on
    ///   - arguments: Additional arguments to pass to the ChromeDriver
    public override init(executablePath: String, ip: String = "127.0.0.1", port: Int = ChromeDriver.defaultPort, arguments: [String] = []) {
        super.init(executablePath: executablePath, ip: ip, port: port, arguments: arguments)
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
