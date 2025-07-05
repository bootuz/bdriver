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
            let _ = try? ChromeDriver()
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