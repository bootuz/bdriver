//
//  BaseDriver.swift
//  Ariadne
//
//  Created by Астемир Бозиев on 03.03.2025.
//

import Foundation
import WebDriver

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
    private let ip: String
    private var process: DriverProcessManager?
    private let arguments: [String]
    
    public init(executablePath: String, ip: String = "127.0.0.1", port: Int = 9515, arguments: [String] = []) {
        self.executablePath = executablePath
        self.ip = ip
        self.port = port
        self.arguments = arguments
    }
    
    public var serviceURL: URL {
        return URL(string: "http://\(ip):\(port)")!
    }
    
    public var isRunning: Bool {
        return process != nil && process!.isRunning
    }
    
    public func start() throws {
        print("🚀 [BaseDriver] Starting ChromeDriver service...")
        print("📂 [BaseDriver] Executable path: \(executablePath)")
        print("🌐 [BaseDriver] IP: \(ip), Port: \(port)")
        
        guard process == nil else { 
            print("⚠️ [BaseDriver] Process already running, skipping start")
            return 
        }
        
        let process = DriverProcessManager()
        process.executableURL = URL(fileURLWithPath: executablePath)
        
        var allArguments = ["--port=\(port)", "--log-level=ALL"]
        allArguments.append(contentsOf: arguments)
        process.arguments = allArguments
        
        print("🔧 [BaseDriver] Process arguments: \(allArguments)")
        
        #if os(macOS)
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        print("📝 [BaseDriver] Output pipes configured for macOS")
        #endif
        
        do {
            print("▶️ [BaseDriver] Attempting to run process...")
            try process.run()
            self.process = process
        } catch {
            print("❌ [BaseDriver] Failed to start process: \(error)")
            throw error
        }
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
