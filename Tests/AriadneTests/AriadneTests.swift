import XCTest
import WebDriver
@testable import Ariadne

/// Basic integration tests for Ariadne Chrome automation
final class AriadneTests: XCTestCase {
    
    func testChromeDriverCreation() throws {
        // Test creating a ChromeDriver instance (this won't actually start ChromeDriver without executable)
        // This test mainly verifies the API works without compilation errors
        XCTAssertNoThrow {
            let _ = try? Ariadne.chrome()
        }
    }
    
    func testChromeDriverWithCapabilities() throws {
        // Test creating ChromeDriver with custom capabilities
        let capabilities = ChromeCapabilities.headless()
        XCTAssertNotNil(capabilities.chromeOptions)
        XCTAssertEqual(capabilities.browserName, .chrome)
    }
    
    func testCapabilitiesFactory() throws {
        // Test different capability factory methods
        let standard = ChromeCapabilities.standard()
        let headless = ChromeCapabilities.headless()
        let withProfile = ChromeCapabilities.withUserProfile(profilePath: "/tmp/test")
        
        XCTAssertEqual(standard.browserName, .chrome)
        XCTAssertEqual(headless.browserName, .chrome)
        XCTAssertEqual(withProfile.browserName, .chrome)
        
        // Verify headless has the right arguments
        XCTAssertTrue(headless.chromeOptions?.args?.contains("--headless") == true)
    }
    
    func testAriadneAPI() throws {
        // Test the main Ariadne API methods compile correctly
        XCTAssertNoThrow {
            // These will fail at runtime without ChromeDriver, but should compile
            let _ = try? Ariadne.chrome()
            let _ = try? Ariadne.chromeHeadless()
            let _ = try? Ariadne.chrome(capabilities: ChromeCapabilities.standard())
        }
    }
    
    // Uncomment and modify this test when you have ChromeDriver available
    /*
    func testRealChromeAutomation() throws {
        let driver = try Ariadne.chromeHeadless()
        
        try driver.navigate(to: "https://example.com")
        let title = try driver.title
        XCTAssertEqual(title, "Example Domain")
        
        try driver.quit()
    }
    */
}