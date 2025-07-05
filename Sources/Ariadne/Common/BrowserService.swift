////
////  BrowserService.swift
////  Ariadne
////
////  Created by Астемир Бозиев on 06.03.2025.
////
//
import Foundation
import WebDriver

/// Protocol for browser service management
public protocol BrowserService: DriverService {
    var browserCapabilities: BrowserCapabilities { get }
}

/// Base implementation of a browser service
open class BaseBrowserService: BrowserService {
    public let executablePath: String
    public let port: Int
    public let ip: String
    public let args: [String]
    public let browserCapabilities: BrowserCapabilities
    private var process: DriverProcessManager?

    /// Initialize a browser service
    /// - Parameters:
    ///   - executablePath: Path to the browser driver executable
    ///   - ip: IP address to bind to
    ///   - port: Port to run the driver on
    ///   - args: Additional arguments to pass to the driver
    ///   - capabilities: Browser capabilities to use
    public init(
        executablePath: String, 
        ip: String = "localhost", 
        port: Int = 9515, 
        args: [String] = [],
        capabilities: BrowserCapabilities
    ) {
        self.executablePath = executablePath
        self.port = port
        self.args = args
        self.ip = ip
        self.browserCapabilities = capabilities
    }

    /// Get the service URL
    open var serviceURL: URL {
        URL(string: "http://\(ip):\(port)")!
    }

    /// Check if the service is running
    public var isRunning: Bool {
        process != nil && process!.isRunning
    }

    /// Start the browser service
    open func start() throws {
        guard !isRunning else { return }

        let process = DriverProcessManager()
        process.executableURL = URL(fileURLWithPath: executablePath)

        var arguments = ["--port=\(port)"]
        arguments.append(contentsOf: args)
        process.arguments = arguments

        #if os(macOS)
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        #endif

        try process.run()
        self.process = process

        try waitForServiceReady(timeout: 10.0)
    }

    /// Stop the browser service
    open func stop() {
        guard let process = process, process.isRunning else { return }
        process.terminate()
        self.process = nil
    }

    /// Wait for the service to be ready
    /// - Parameter timeout: Timeout in seconds
    /// - Throws: DriverError if the service is not ready within the timeout
    private func waitForServiceReady(timeout: TimeInterval) throws {
        let startTime = Date()
        var lastError: Error?

        while Date().timeIntervalSince(startTime) < timeout {
            guard isRunning else {
                throw DriverError.driverNotReady(nil)
            }
            
            // Try to connect to the service - simple synchronous check
            do {
                let _ = try Data(contentsOf: serviceURL)
                return // Service is ready
            } catch {
                lastError = error
            }
            
            Thread.sleep(forTimeInterval: 0.1)
        }

        throw DriverError.driverNotReady(lastError)
    }

    deinit {
        stop()
    }
}

