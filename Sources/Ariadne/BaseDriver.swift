//
//  BaseDriver.swift
//  Ariadne
//
//  Created by Астемир Бозиев on 03.03.2025.
//

import Foundation
import WebDriver

/// Protocol defining the core WebDriver functionality
public protocol WebDriverProtocol {
    func send<Req: Request>(_ request: Req) throws -> Req.Response
}

/// Base implementation of WebDriver that handles communication with the WebDriver server
public class BaseDriver: WebDriverProtocol {
    private let httpDriver: HTTPWebDriver
    private let driverService: DriverService
    
    public init(service: DriverService, wireProtocol: WireProtocol = .w3c,  start: Bool = true) throws {
        self.driverService = service
        self.httpDriver = HTTPWebDriver(endpoint: service.serviceURL, wireProtocol: wireProtocol)

        if start {
            try startDriver()
        }
    }
    
    private func startDriver() throws {
        try driverService.start()
        
        // Wait for Driver to be ready
        try waitForDriverReady(timeout: 5)
    }
    
    public static func start(service: DriverService) throws -> BaseDriver {
        return try BaseDriver(service: service)
    }
    
    private func waitForDriverReady(timeout: TimeInterval) throws {
        let startTime = Date()
        var lastError: Error?
        
        while Date().timeIntervalSince(startTime) < timeout {
            do {
                _ = try httpDriver.status
                return
            } catch {
                lastError = error
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
        
        throw DriverError.driverNotReady(lastError)
    }
    
    public func send<Req>(_ request: Req) throws -> Req.Response where Req : Request {
        try httpDriver.send(request)
    }
    
    deinit {
        driverService.stop()
    }
}

/// Protocol for driver service management
public protocol DriverService {
    var serviceURL: URL { get }
    var isRunning: Bool { get }
    
    func start() throws
    func stop()
}

/// Default implementation of DriverService that manages a driver process
public class DefaultDriverService: DriverService {
    private let executablePath: String
    private let port: Int
    private var process: DriverProcessManager?
    private let arguments: [String]
    
    public init(executablePath: String, port: Int = 9515, arguments: [String] = []) {
        self.executablePath = executablePath
        self.port = port
        self.arguments = arguments
    }
    
    public var serviceURL: URL {
        return URL(string: "http://localhost:\(port)")!
    }
    
    public var isRunning: Bool {
        return process != nil && process!.isRunning
    }
    
    public func start() throws {
        guard process == nil else { return }
        
        let process = DriverProcessManager()
        process.executableURL = URL(fileURLWithPath: executablePath)
        
        var allArguments = ["--port=\(port)"]
        allArguments.append(contentsOf: arguments)
        process.arguments = allArguments
        
        #if os(macOS)
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        #endif
        
        try process.run()
        self.process = process
    }
    
    public func stop() {
        guard let process = process, process.isRunning else { return }
        process.terminate()
        self.process = nil
    }
    
    deinit {
        stop()
    }
}

/// Errors specific to WebDriver
public enum DriverError: Error, CustomStringConvertible {
    case driverNotReady(Error?)
    case browserNotFound
    case driverProcessFailed(Error)
    
    public var description: String {
        switch self {
        case .driverNotReady(let error):
            if let error = error {
                return "WebDriver failed to start: \(error)"
            } else {
                return "WebDriver failed to start within the timeout period"
            }
        case .browserNotFound:
            return "Could not find browser"
        case .driverProcessFailed(let error):
            return "WebDriver process failed: \(error)"
        }
    }
}
