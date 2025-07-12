//
//  BuildTests.swift
//  Ariadne
//
//  Created by Claude on 05.07.2025.
//

import Testing
import WebDriver
@testable import Ariadne

@Suite("Build Tests") final class BuildTests {
    
    @Test func testBasicImports() {
        // Test that basic imports work
        let caps = ChromeCapabilities.standard()
        #expect(caps.browserName == .chrome)
    }
    
    @Test func testDriverCreation() {
        // Test that driver can be created (without starting)
        do {
            let _ = try ChromeDriver(start: false)
        } catch {
            // Expected to fail without ChromeDriver installed, but should compile
        }
    }
    
    @Test func testAriadneFactory() {
        // Test that Ariadne factory methods compile
        do {
            let _ = try Ariadne.chrome()
        } catch {
            // Expected to fail without ChromeDriver installed, but should compile
        }
    }
    
    @Test func testCapabilitiesBuilder() {
        // Test that capabilities builder works
        let caps = ChromeCapabilities.standard()
            .addArgument("--headless")
            .setBinary("/path/to/chrome")
            .enableDetach()
        
        #expect(caps.chromeOptions?.args?.contains("--headless") == true)
        #expect(caps.chromeOptions?.binary == "/path/to/chrome")
        #expect(caps.chromeOptions?.detach == true)
    }
    
    @Test func testDriverService() {
        // Test that driver service can be created
        do {
            let service = DefaultDriverService(executablePath: "/usr/local/bin/chromedriver")
            #expect(service.serviceURL.absoluteString == "http://localhost:9515")
            #expect(service.isRunning == false)
        }
    }
    
    @Test func testLogging() {
        // Test that logging system works
        let logger = AriadneLogger.shared
        logger.configure(level: .debug, categories: [.test])
        
        ariadneInfo("Test message", category: .test)
        
        #expect(AriadneLogLevel.info.rawValue == 2)
        #expect(AriadneLogCategory.test.rawValue == "test")
    }
}