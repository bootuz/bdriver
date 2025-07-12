//
//  TestUtilities.swift
//  Ariadne
//
//  Created by Claude on 05.07.2025.
//

import Foundation
import WebDriver
@testable import Ariadne

/// Test utilities for Ariadne testing
public final class TestUtilities: Sendable {

    /// Shared instance for test utilities
    public static let shared = TestUtilities()
    
    private init() {}
    
    // MARK: - Test Driver Creation
    
    /// Create a test ChromeDriver instance
    /// - Parameters:
    ///   - headless: Whether to run in headless mode
    ///   - timeout: Startup timeout
    /// - Returns: ChromeDriver instance or nil if creation fails
    public func createTestDriver(headless: Bool = true, timeout: TimeInterval = 10.0) -> ChromeDriver? {
        do {
            let capabilities = headless ? ChromeCapabilities.forTesting() : ChromeCapabilities.standard()
            let driver = try ChromeDriver(capabilities: capabilities, start: false)
            
            // Only start if ChromeDriver is available
            if isChromDriverAvailable() {
                try driver.start()
                return driver
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    /// Check if ChromeDriver is available on the system
    /// - Returns: True if ChromeDriver is available
    public func isChromDriverAvailable() -> Bool {
        let possiblePaths = [
            "/usr/local/bin/chromedriver",
            "/usr/bin/chromedriver",
            "/opt/homebrew/bin/chromedriver"
        ]
        
        return possiblePaths.contains { FileManager.default.fileExists(atPath: $0) }
    }
    
    /// Create a test driver with custom capabilities
    /// - Parameter capabilities: Custom capabilities
    /// - Returns: ChromeDriver instance or nil if creation fails
    public func createTestDriver(capabilities: ChromeCapabilities) -> ChromeDriver? {
        do {
            let driver = try ChromeDriver(capabilities: capabilities, start: false)
            
            if isChromDriverAvailable() {
                try driver.start()
                return driver
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    // MARK: - Test Page Helpers
    
    /// Create a simple test HTML page
    /// - Returns: HTML string for testing
    public func createTestHTML() -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Test Page</title>
        </head>
        <body>
            <h1 id="title">Test Page</h1>
            <form id="test-form">
                <input type="text" id="username" name="username" placeholder="Username">
                <input type="password" id="password" name="password" placeholder="Password">
                <select id="country" name="country">
                    <option value="us">United States</option>
                    <option value="ca">Canada</option>
                    <option value="uk">United Kingdom</option>
                </select>
                <input type="checkbox" id="terms" name="terms">
                <label for="terms">Accept Terms</label>
                <button type="submit" id="submit">Submit</button>
            </form>
            
            <div id="results"></div>
            
            <table id="test-table">
                <tr>
                    <th>Name</th>
                    <th>Age</th>
                    <th>City</th>
                </tr>
                <tr>
                    <td>John</td>
                    <td>25</td>
                    <td>New York</td>
                </tr>
                <tr>
                    <td>Jane</td>
                    <td>30</td>
                    <td>Los Angeles</td>
                </tr>
            </table>
            
            <div id="shadow-host"></div>
            
            <script>
                // Create shadow DOM for testing
                const shadowHost = document.getElementById('shadow-host');
                const shadowRoot = shadowHost.attachShadow({mode: 'open'});
                shadowRoot.innerHTML = '<button id="shadow-button">Shadow Button</button>';
                
                // Form submission handler
                document.getElementById('test-form').addEventListener('submit', function(e) {
                    e.preventDefault();
                    document.getElementById('results').innerHTML = 'Form submitted!';
                });
                
                // Click counter
                let clickCount = 0;
                document.getElementById('title').addEventListener('click', function() {
                    clickCount++;
                    this.setAttribute('data-clicks', clickCount);
                });
            </script>
        </body>
        </html>
        """
    }
    
    /// Create a test HTML file and return its file:// URL
    /// - Returns: File URL for the test HTML
    public func createTestHTMLFile() -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let testFile = tempDir.appendingPathComponent("ariadne-test-\(UUID().uuidString).html")
        
        do {
            try createTestHTML().write(to: testFile, atomically: true, encoding: .utf8)
            return testFile
        } catch {
            return nil
        }
    }
    
    // MARK: - Test Data Helpers
    
    /// Generate test form data
    /// - Returns: Dictionary of form field data
    public func generateTestFormData() -> [String: String] {
        return [
            "#username": "testuser",
            "#password": "testpass123",
            "#country": "us",
            "#terms": "true"
        ]
    }
    
    /// Generate test file for upload
    /// - Returns: Path to test file
    public func createTestFile() -> String? {
        let tempDir = NSTemporaryDirectory()
        let fileName = "ariadne-test-\(UUID().uuidString).txt"
        let filePath = (tempDir as NSString).appendingPathComponent(fileName)
        
        let content = "This is a test file for Ariadne WebDriver testing.\nCreated at: \(Date())"
        
        do {
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
            return filePath
        } catch {
            return nil
        }
    }
    
    /// Generate test image file
    /// - Returns: Path to test image file
    public func createTestImage() -> String? {
        let tempDir = NSTemporaryDirectory()
        let fileName = "ariadne-test-\(UUID().uuidString).png"
        let filePath = (tempDir as NSString).appendingPathComponent(fileName)
        
        // Create a simple 1x1 PNG image
        let pngData = Data([
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
            0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
            0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
            0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
            0x42, 0x60, 0x82
        ])
        
        do {
            try pngData.write(to: URL(fileURLWithPath: filePath))
            return filePath
        } catch {
            return nil
        }
    }
    
    // MARK: - Test Assertions
    
    /// Assert that an element exists and is visible
    /// - Parameters:
    ///   - driver: ChromeDriver instance
    ///   - locator: Element locator
    ///   - timeout: Timeout for waiting
    /// - Returns: True if element exists and is visible
    public func assertElementVisible(driver: ChromeDriver, locator: ElementLocator, timeout: TimeInterval = 5.0) -> Bool {
        do {
            let element = try driver.findElement(by: locator)
            return try element.displayed
        } catch {
            return false
        }
    }
    
    /// Assert that an element exists and is clickable
    /// - Parameters:
    ///   - driver: ChromeDriver instance
    ///   - locator: Element locator
    ///   - timeout: Timeout for waiting
    /// - Returns: True if element exists and is clickable
    public func assertElementClickable(driver: ChromeDriver, locator: ElementLocator, timeout: TimeInterval = 5.0) -> Bool {
        do {
            let element = try driver.findElement(by: locator)
            let enabled = try element.enabled
            let displayed = try element.displayed
            return enabled && displayed
        } catch {
            return false
        }
    }
    
    /// Assert that text is present in page
    /// - Parameters:
    ///   - driver: ChromeDriver instance
    ///   - text: Text to search for
    /// - Returns: True if text is found
    public func assertTextPresent(driver: ChromeDriver, text: String) -> Bool {
        do {
            let source = try driver.pageSource
            return source.contains(text)
        } catch {
            return false
        }
    }
    
    /// Assert that title matches expected value
    /// - Parameters:
    ///   - driver: ChromeDriver instance
    ///   - expectedTitle: Expected title
    /// - Returns: True if title matches
    public func assertTitle(driver: ChromeDriver, expectedTitle: String) -> Bool {
        do {
            let title = try driver.title
            return title == expectedTitle
        } catch {
            return false
        }
    }
    
    /// Assert that URL contains expected text
    /// - Parameters:
    ///   - driver: ChromeDriver instance
    ///   - expectedText: Expected text in URL
    /// - Returns: True if URL contains text
    public func assertURLContains(driver: ChromeDriver, expectedText: String) -> Bool {
        do {
            let url = try driver.currentURL.absoluteString
            return url.contains(expectedText)
        } catch {
            return false
        }
    }
    
    // MARK: - Performance Helpers
    
    /// Measure execution time of a block
    /// - Parameter block: Block to measure
    /// - Returns: Execution time in seconds
    public func measureTime(_ block: () throws -> Void) rethrows -> TimeInterval {
        let startTime = Date()
        try block()
        return Date().timeIntervalSince(startTime)
    }
    
    /// Measure execution time of an async block
    /// - Parameter block: Async block to measure
    /// - Returns: Execution time in seconds
    @available(macOS 10.15, *)
    public func measureTimeAsync(_ block: () async throws -> Void) async rethrows -> TimeInterval {
        let startTime = Date()
        try await block()
        return Date().timeIntervalSince(startTime)
    }
    
    // MARK: - Memory Helpers
    
    /// Get current memory usage
    /// - Returns: Memory usage in bytes
    public func getCurrentMemoryUsage() -> UInt64 {
        let task = mach_task_self_
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(task, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
    
    // MARK: - Cleanup Helpers
    
    /// Clean up test files
    /// - Parameter paths: File paths to clean up
    public func cleanupTestFiles(_ paths: [String]) {
        for path in paths {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
    
    /// Clean up test driver
    /// - Parameter driver: Driver to clean up
    public func cleanupTestDriver(_ driver: ChromeDriver?) {
        if let driver = driver {
            try? driver.quit()
        }
    }
    
    // MARK: - Wait Helpers
    
    /// Wait for condition with timeout
    /// - Parameters:
    ///   - condition: Condition to wait for
    ///   - timeout: Maximum time to wait
    ///   - interval: Polling interval
    /// - Returns: True if condition was met
    public func waitFor(condition: () -> Bool, timeout: TimeInterval = 10.0, interval: TimeInterval = 0.1) -> Bool {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            if condition() {
                return true
            }
            Thread.sleep(forTimeInterval: interval)
        }
        
        return false
    }
    
    /// Wait for condition with timeout (throws on timeout)
    /// - Parameters:
    ///   - condition: Condition to wait for
    ///   - timeout: Maximum time to wait
    ///   - interval: Polling interval
    /// - Throws: TestUtilityError.timeout if condition is not met
    public func waitForOrThrow(condition: () -> Bool, timeout: TimeInterval = 10.0, interval: TimeInterval = 0.1) throws {
        if !waitFor(condition: condition, timeout: timeout, interval: interval) {
            throw TestUtilityError.timeout(timeout)
        }
    }
}

/// Test utility errors
public enum TestUtilityError: Error, LocalizedError {
    case timeout(TimeInterval)
    case fileCreationFailed(String)
    case driverCreationFailed(String)
    case assertionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .timeout(let timeout):
            return "Timeout after \(timeout) seconds"
        case .fileCreationFailed(let reason):
            return "File creation failed: \(reason)"
        case .driverCreationFailed(let reason):
            return "Driver creation failed: \(reason)"
        case .assertionFailed(let reason):
            return "Assertion failed: \(reason)"
        }
    }
}

/// Test configuration for different test scenarios
public struct TestConfiguration: Sendable {
    public let headless: Bool
    public let timeout: TimeInterval
    public let windowSize: (width: Int, height: Int)?
    public let userAgent: String?
    public let language: String?
    public let additionalArguments: [String]
    
    public init(
        headless: Bool = true,
        timeout: TimeInterval = 10.0,
        windowSize: (width: Int, height: Int)? = nil,
        userAgent: String? = nil,
        language: String? = nil,
        additionalArguments: [String] = []
    ) {
        self.headless = headless
        self.timeout = timeout
        self.windowSize = windowSize
        self.userAgent = userAgent
        self.language = language
        self.additionalArguments = additionalArguments
    }
    
    /// Create capabilities from test configuration
    /// - Returns: ChromeCapabilities configured for testing
    public func createCapabilities() -> ChromeCapabilities {
        var caps = headless ? ChromeCapabilities.headless() : ChromeCapabilities.standard()
        
        // Add custom arguments
        for arg in additionalArguments {
            caps = caps.addArgument(arg)
        }
        
        // Set user agent
        if let userAgent = userAgent {
            caps = caps.addArgument("--user-agent=\(userAgent)")
        }
        
        // Set language
        if let language = language {
            caps = caps.addArgument("--lang=\(language)")
        }
        
        // Set window size
        if let windowSize = windowSize {
            caps = caps.addArgument("--window-size=\(windowSize.width),\(windowSize.height)")
        }
        
        return caps
    }
    
    /// Default configuration for unit tests
    public static let unitTest = TestConfiguration(
        headless: true,
        timeout: 5.0,
        windowSize: (800, 600),
        additionalArguments: ["--no-sandbox", "--disable-dev-shm-usage"]
    )
    
    /// Default configuration for integration tests
    public static let integrationTest = TestConfiguration(
        headless: true,
        timeout: 30.0,
        windowSize: (1024, 768),
        additionalArguments: ["--no-sandbox", "--disable-dev-shm-usage"]
    )
    
    /// Default configuration for performance tests
    public static let performanceTest = TestConfiguration(
        headless: true,
        timeout: 60.0,
        windowSize: (1920, 1080),
        additionalArguments: ["--no-sandbox", "--disable-dev-shm-usage", "--disable-extensions"]
    )
}
