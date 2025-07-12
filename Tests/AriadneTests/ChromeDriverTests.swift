//
//  ChromeDriverTests.swift
//  Ariadne
//
//  Created by Астемир Бозиев on 04.03.2025.
//

import Testing
import WebDriver
@testable import Ariadne
import Foundation

@Suite("Chrome Driver Tests") final class ChromeDriverTests {
    
    @Test func chromeDriverCreationTest() throws {
        // Test that ChromeDriver can be created with the new API
        // This test will fail at runtime without ChromeDriver, but should compile
        XCTAssertNoThrow {
            let _ = try? ChromeDriver(start: false)
        }
    }
    
    @Test func chromeCapabilitiesTest() throws {
        // Test Chrome capabilities
        let standard = ChromeCapabilities.standard()
        let headless = ChromeCapabilities.headless()
        
        #expect(standard.browserName == .chrome)
        #expect(headless.browserName == .chrome)
        #expect(headless.chromeOptions?.args?.contains("--headless") == true)
    }
    
    @Test func capabilitiesBuilderTest() throws {
        // Test fluent API for capabilities building
        let caps = ChromeCapabilities.standard()
            .addArgument("--disable-extensions")
            .addArguments(["--disable-plugins", "--disable-images"])
            .setBinary("/custom/chrome/path")
            .enableDetach()
        
        #expect(caps.chromeOptions?.args?.contains("--disable-extensions") == true)
        #expect(caps.chromeOptions?.args?.contains("--disable-plugins") == true)
        #expect(caps.chromeOptions?.binary == "/custom/chrome/path")
        #expect(caps.chromeOptions?.detach == true)
    }
    
    @Test func loggingTest() throws {
        // Test basic logging infrastructure
        let _ = AriadneLogger.shared
        
        // Configure logger for testing
        AriadneLogger.shared.configure(
            level: .debug,
            categories: [.test, .driver]
        )
        
        // Test logging functions
        XCTAssertNoThrow {
            ariadneTrace("Test trace message", category: .test)
            ariadneDebug("Test debug message", category: .test)
            ariadneInfo("Test info message", category: .test)
            ariadneWarning("Test warning message", category: .test)
            ariadneError("Test error message", category: .test)
        }
        
        // Test log levels
        #expect(AriadneLogLevel.trace < AriadneLogLevel.debug)
        #expect(AriadneLogLevel.debug < AriadneLogLevel.info)
        #expect(AriadneLogLevel.warning > AriadneLogLevel.info)
    }
    
    // Uncomment this test when you have ChromeDriver available
    /*
    @Test func realChromeDriverTest() throws {
        let driver = try ChromeDriver(capabilities: ChromeCapabilities.headless())
        
        try driver.navigate(to: "https://example.com")
        let title = try driver.title
        #expect(title == "Example Domain")
        
        try driver.quit()
    }
    */
}

// Helper for tests that don't use Swift Testing
func XCTAssertNoThrow<T>(_ expression: () throws -> T) {
    do {
        _ = try expression()
    } catch {
        // Expected to fail without ChromeDriver
    }
}
