//
//  RealChromeTest.swift
//  Ariadne
//
//  Live test with actual ChromeDriver
//

import Testing
import WebDriver
@testable import Ariadne
import Foundation

@Suite("Real Chrome Automation Tests") final class RealChromeTest {
    
    @Test func realChromeDriverTest() async throws {
        // Create a custom service pointing to your ChromeDriver
        let service = ChromeDriverService(executablePath: "/Users/nart/Desktop/chromedriver-mac-arm64/chromedriver")
        // Create driver with headless mode for non-intrusive testing
        let capabilities = ChromeCapabilities.standard()
        capabilities.timeouts?.implicit = 10
        let driver = try ChromeDriver(service: service, capabilities: capabilities)

        print("🚀 Starting Chrome automation test...")
        
        // Test navigation
        print("📍 Navigating to example.com...")
        try driver.navigate(to: "https://example.com")
        // Test getting page title
        let title = try driver.title
        print("📄 Page title: '\(title)'")
        #expect(title == "Example Domain")
        
        // Test getting current URL
        let currentURL = try driver.currentURL
        print("🔗 Current URL: \(currentURL)")
        #expect(currentURL.absoluteString == "https://example.com/")
        
        // Test finding an element
        print("🔍 Finding page heading...")
        let heading = try driver.findElement(by: .tagName("h1"))
        let headingText = try heading.text
        print("📝 Heading text: '\(headingText)'")
        #expect(headingText == "Example Domain")
        
        // Test taking a screenshot
        print("📸 Taking screenshot...")
        let screenshotData = try driver.screenshot()
        print("📊 Screenshot size: \(screenshotData.count) bytes")
        #expect(screenshotData.count > 0)
        
        // Test window management
        print("🪟 Testing window management...")
        let (width, height) = try driver.windowSize
        print("📐 Current window size: \(width)x\(height)")
        
        // Resize window
        try driver.setWindowSize(width: 1024, height: 768)
        let (newWidth, newHeight) = try driver.windowSize
        print("📐 New window size: \(newWidth)x\(newHeight)")
        #expect(newWidth == 1024)
        #expect(newHeight == 768)
        

        // Test navigation history
        print("🔄 Testing navigation...")
        try driver.navigate(to: "https://httpbin.org/html")

        // Go back
        try driver.back()
        let backTitle = try driver.title
        // Clean up
        print(backTitle)
        print("🛑 Quitting Chrome...")
        try driver.quit()
        
        print("✅ Chrome automation test completed successfully!")
    }
    
    @Test func testErrorHandling() async throws {
        // Test error handling with invalid element
        let service = ChromeDriverService(executablePath: "/Users/nart/Desktop/chromedriver")
        let capabilities = ChromeCapabilities.headless()
        let driver = try ChromeDriver(service: service, capabilities: capabilities)
        
        try driver.navigate(to: "https://example.com")
        
        // Try to find a non-existent element
        do {
            let _ = try driver.findElement(by: .id("non-existent-element"))
            #expect(Bool(false), "Should have thrown an error for non-existent element")
        } catch {
            print("✅ Correctly caught error for non-existent element: \(error)")
        }
        
        try driver.quit()
    }
    
    @Test func testFormInteraction() async throws {
        // Test basic form interaction
        let service = ChromeDriverService(executablePath: "/Users/nart/Desktop/chromedriver")
        let capabilities = ChromeCapabilities.headless()
        let driver = try ChromeDriver(service: service, capabilities: capabilities)
        
        // Navigate to httpbin which has forms
        try driver.navigate(to: "https://httpbin.org/forms/post")
        
        // Find and interact with form elements
        let customerNameField = try driver.findElement(by: .name("custname"))
        try customerNameField.sendKeys(.text("John Doe", typingStrategy: .assumeUSKeyboard))
        
        let emailField = try driver.findElement(by: .name("custemail"))
        try emailField.sendKeys(.text("john@example.com", typingStrategy: .assumeUSKeyboard))
        
        // Get the values back to verify using getAttribute
        let nameValue = try customerNameField.getAttribute(name: "value")
        let emailValue = try emailField.getAttribute(name: "value")
        
        print("📝 Name field value: \(nameValue ?? "nil")")
        print("📧 Email field value: \(emailValue ?? "nil")")
        
        #expect(nameValue == "John Doe")
        #expect(emailValue == "john@example.com")
        
        try driver.quit()
        print("✅ Form interaction test completed!")
    }
}
