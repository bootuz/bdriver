//
//  DebugChromeTest.swift
//  Ariadne
//
//  Debug test with detailed logging
//

import Testing
import WebDriver
@testable import Ariadne
import Foundation

@Suite("Debug Chrome Tests") final class DebugChromeTest {
    
    @Test func debugChromeDriverTest() async throws {
        print("🔍 Starting debug test...")
        
        // Step 1: Check ChromeDriver exists and is executable
        let chromeDriverPath = "/Users/nart/Desktop/chromedriver-mac-arm64/chromedriver"
        print("📂 Checking ChromeDriver at: \(chromeDriverPath)")
        
        guard FileManager.default.fileExists(atPath: chromeDriverPath) else {
            print("❌ ChromeDriver not found at path")
            throw NSError(domain: "DebugTest", code: 1, userInfo: [NSLocalizedDescriptionKey: "ChromeDriver not found"])
        }
        
        guard FileManager.default.isExecutableFile(atPath: chromeDriverPath) else {
            print("❌ ChromeDriver is not executable")
            throw NSError(domain: "DebugTest", code: 2, userInfo: [NSLocalizedDescriptionKey: "ChromeDriver not executable"])
        }
        
        print("✅ ChromeDriver exists and is executable")
        
        // Step 2: Check Chrome version
        print("🌐 Checking Chrome version...")
        let chromeVersionTask = Process()
        chromeVersionTask.executableURL = URL(fileURLWithPath: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")
        chromeVersionTask.arguments = ["--version"]
        
        let pipe = Pipe()
        chromeVersionTask.standardOutput = pipe
        
        do {
            try chromeVersionTask.run()
            chromeVersionTask.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "Unknown"
            print("🌐 Chrome version: \(output.trimmingCharacters(in: .whitespacesAndNewlines))")
        } catch {
            print("⚠️ Could not check Chrome version: \(error)")
        }
        
        // Step 3: Test ChromeDriver version
        print("🚗 Checking ChromeDriver version...")
        let chromeDriverVersionTask = Process()
        chromeDriverVersionTask.executableURL = URL(fileURLWithPath: chromeDriverPath)
        chromeDriverVersionTask.arguments = ["--version"]
        
        let driverPipe = Pipe()
        chromeDriverVersionTask.standardOutput = driverPipe
        
        do {
            try chromeDriverVersionTask.run()
            chromeDriverVersionTask.waitUntilExit()
            
            let data = driverPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "Unknown"
            print("🚗 ChromeDriver version: \(output.trimmingCharacters(in: .whitespacesAndNewlines))")
        } catch {
            print("⚠️ Could not check ChromeDriver version: \(error)")
        }
        
        // Step 4: Try to create service with different port
        print("🔧 Creating ChromeDriver service...")
        let service = ChromeDriverService(executablePath: chromeDriverPath, port: 9516)
        print("✅ Service created. URL: \(service.serviceURL)")
        
        // Step 5: Try to start service manually
        print("🚀 Attempting to start ChromeDriver service...")
        do {
            try service.start()
            print("✅ ChromeDriver service started successfully")
            
            // Give it a moment
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            if service.isRunning {
                print("✅ Service is running")
            } else {
                print("❌ Service not running after start")
                throw NSError(domain: "DebugTest", code: 3, userInfo: [NSLocalizedDescriptionKey: "Service not running"])
            }
            
        } catch {
            print("❌ Failed to start ChromeDriver service: \(error)")
            print("📋 Error details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("📋 Error domain: \(nsError.domain)")
                print("📋 Error code: \(nsError.code)")
                print("📋 Error userInfo: \(nsError.userInfo)")
            }
            throw error
        }
        
        // Step 6: Try to create driver
        print("🚙 Creating ChromeDriver instance...")
        let capabilities = ChromeCapabilities.standard()
        
        do {
            // Don't auto-start since we already started the service
            let driver = try ChromeDriver(service: service, capabilities: capabilities, start: false)
            print("✅ ChromeDriver instance created successfully")
            
            // Step 7: Test basic navigation
            print("🌍 Testing navigation to data URL...")
            try driver.navigate(to: "data:text/html,<html><head><title>Test Page</title></head><body><h1>Hello Debug!</h1></body></html>")
            print("✅ Navigation successful")
            
            // Step 8: Test getting title
            print("📄 Getting page title...")
            let title = try driver.title
            print("📄 Page title: '\(title)'")
            #expect(title == "Test Page")
            
            // Step 9: Test element finding
            print("🔍 Finding heading element...")
            let heading = try driver.findElement(by: .tagName("h1"))
            let headingText = try heading.text
            print("📝 Heading text: '\(headingText)'")
            #expect(headingText == "Hello Debug!")
            
            // Step 10: Clean up
            print("🧹 Cleaning up...")
            try driver.quit()
            print("✅ Driver quit successfully")
            
        } catch {
            print("❌ Failed to create or use ChromeDriver: \(error)")
            print("📋 Error details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("📋 Error domain: \(nsError.domain)")
                print("📋 Error code: \(nsError.code)")
                print("📋 Error userInfo: \(nsError.userInfo)")
            }
            
            // Clean up service
            service.stop()
            throw error
        }
        
        // Final cleanup
        service.stop()
        print("🎉 Debug test completed successfully!")
    }
}