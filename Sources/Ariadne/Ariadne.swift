// The Swift Programming Language
// https://docs.swift.org/swift-book

// Ariadne - WebDriver Client for Swift
// https://github.com/yourusername/Ariadne

import Foundation
import WebDriver

/// Main entry point for the Ariadne library
public enum Ariadne {
    /// Create a new Chrome driver with default settings
    /// - Returns: A configured ChromeDriver instance
    public static func chrome() throws -> ChromeDriver {
        try ChromeDriver()
    }
    
    /// Create a new Chrome driver with custom capabilities
    /// - Parameter capabilities: The capabilities to use
    /// - Returns: A configured ChromeDriver instance
    public static func chrome(capabilities: ChromeCapabilities) throws -> ChromeDriver {
        try ChromeDriver(capabilities: capabilities)
    }
    
    /// Create a new Chrome driver in headless mode
    /// - Returns: A configured ChromeDriver instance in headless mode
    public static func chromeHeadless() throws -> ChromeDriver {
        try ChromeDriver(capabilities: ChromeCapabilities.headless())
    }
    
    /// Attach to an existing Chrome driver instance
    /// - Parameters:
    ///   - ip: The IP address of the driver
    ///   - port: The port of the driver
    ///   - capabilities: The capabilities to use for the session
    /// - Returns: A ChromeDriver instance connected to the existing driver
    public static func attachToChrome(ip: String = ChromeDriver.defaultIp, port: Int = ChromeDriver.defaultPort, capabilities: ChromeCapabilities = ChromeCapabilities.standard()) throws -> ChromeDriver {
        try ChromeDriver.attach(ip: ip, port: port, capabilities: capabilities)
    }
    
    /// Version of the Ariadne library
    public static let version = "0.1.0"
}
