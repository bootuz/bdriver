//
//  ElementLocator+CSS.swift
//  Ariadne
//
//  Created by Астемир Бозиев on 04.03.2025.
//

import WebDriver

extension ElementLocator {
    /// Creates a CSS selector that matches elements by their data-testid attribute
    public static func testId(_ value: String) -> Self {
        Self.cssSelector("[data-testid=\"\(value)\"]")
    }
    
    /// Creates a CSS selector that matches elements by their role attribute
    public static func role(_ value: String) -> Self {
        Self.cssSelector("[role=\"\(value)\"]")
    }
}
