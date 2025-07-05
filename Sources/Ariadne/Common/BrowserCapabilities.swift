//
//  for.swift
//  Ariadne
//
//  Created by Астемир Бозиев on 04.03.2025.
//


import WebDriver

/// Base protocol for browser-specific capabilities
public protocol BrowserCapabilities: Capabilities {
    /// The browser name
    var browserName: String { get }
    
    /// The browser version (optional)
    var browserVersion: String? { get set }
    
    /// Path to the browser binary (optional)
    var browserBinary: String? { get set }
    
    /// Additional browser arguments
    var arguments: [String] { get set }
}

/// Default implementation for browser capabilities
open class BaseBrowserCapabilities: Capabilities, BrowserCapabilities {
    public var browserName: String
    public var browserVersion: String?
    public var browserBinary: String?
    public var arguments: [String] = []
    
    public init(browserName: String) {
        self.browserName = browserName
        super.init()
    }
    
    private enum CodingKeys: String, CodingKey {
        case browserName
        case browserVersion
        case browserBinary
        case arguments
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        browserName = try container.decode(String.self, forKey: .browserName)
        browserVersion = try container.decodeIfPresent(String.self, forKey: .browserVersion)
        browserBinary = try container.decodeIfPresent(String.self, forKey: .browserBinary)
        arguments = try container.decodeIfPresent([String].self, forKey: .arguments) ?? []
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(browserName, forKey: .browserName)
        try container.encodeIfPresent(browserVersion, forKey: .browserVersion)
        try container.encodeIfPresent(browserBinary, forKey: .browserBinary)
        try container.encode(arguments, forKey: .arguments)
        try super.encode(to: encoder)
    }
}