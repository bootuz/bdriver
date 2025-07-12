#!/usr/bin/env swift

// Manual Chrome Automation Demo
// Prerequisites: ChromeDriver running on port 9515
// Start with: /Users/nart/Desktop/chromedriver --port=9515

import Foundation

print("""
🤖 Ariadne Manual Demo Script
============================

This script demonstrates the Ariadne API usage.
Make sure ChromeDriver is running first:

    /Users/nart/Desktop/chromedriver --port=9515

Then you can create automation scripts like this:

import Ariadne

// Create driver that connects to running ChromeDriver
let driver = try ChromeDriver.attach(ip: "localhost", port: 9515, 
                                   capabilities: ChromeCapabilities.headless())

// Basic navigation
try driver.navigate(to: "https://example.com")
print("Current page: \\(try driver.title)")

// Find elements
let heading = try driver.findElement(by: .tagName("h1"))
print("Page heading: \\(try heading.text)")

// Take screenshot
let screenshot = try driver.screenshot()
print("Screenshot captured: \\(screenshot.count) bytes")

// Execute JavaScript
try driver.executeScript("console.log('Hello from Ariadne!');")

// Window management
try driver.setWindowSize(width: 1024, height: 768)
let (width, height) = try driver.windowSize
print("Window size: \\(width)x\\(height)")

// Navigation
try driver.navigate(to: "https://httpbin.org/html")
try driver.back()

// Clean up
try driver.quit()

Core Ariadne Features:
• ✅ Simple factory methods: Ariadne.chrome(), Ariadne.chromeHeadless()
• ✅ Attach to existing instances: ChromeDriver.attach()
• ✅ Basic navigation: navigate(), back(), forward(), refresh()
• ✅ Element finding: findElement(by:), findElements(by:)
• ✅ Screenshots: screenshot()
• ✅ Window management: windowSize, setWindowSize(), maximize()
• ✅ JavaScript execution: executeScript()
• ✅ Logging: AriadneLogger with multiple levels
• ✅ Cross-platform ChromeDriver path detection

The simplified Ariadne library focuses on essential Chrome automation
without enterprise complexity!
""")

// Test basic functionality without actually running (since we can't import in a script)
print("\n📦 Library Structure:")
print("Sources/Ariadne/")
print("├── Ariadne.swift (main API)")
print("├── BaseDriver.swift (service management)")
print("├── Chrome/")
print("│   ├── ChromeDriver.swift (core driver)")
print("│   ├── ChromeCapabilities.swift")
print("│   └── ChromePaths.swift")
print("└── Common/")
print("    ├── AriadneLogger.swift")
print("    ├── ElementLocator+CSS.swift")
print("    └── [other utilities]")

print("\n🎯 Total simplified codebase: ~800-1000 lines vs 4000+ before!")