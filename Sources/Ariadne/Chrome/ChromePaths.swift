//
//  ChromePaths.swift
//  Ariadne
//
//  Created by Астемир Бозиев on 04.03.2025.
//

import Foundation

public enum ChromePaths {
    #if os(Windows)
    public static let windowsDriverPath = findWindowsDriverPath()
    
    private static func findWindowsDriverPath() -> String {
        // Look in common installation locations
        let possiblePaths = [
            "\(WindowsSystemPaths.programFilesX86)\\Google\\Chrome\\Application\\chromedriver.exe",
            "\(WindowsSystemPaths.programFilesX86)\\ChromeDriver\\chromedriver.exe"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        // Default to expecting it in PATH
        return "chromedriver.exe"
    }
    #endif
    
    #if os(macOS)
    public static let macDriverPath = findMacDriverPath()
    
    private static func findMacDriverPath() -> String {
        // Look in common installation locations
        let possiblePaths = [
            "/usr/local/bin/chromedriver",
            "/usr/bin/chromedriver",
            "/opt/homebrew/bin/chromedriver"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        // Default to expecting it in PATH
        return "chromedriver"
    }
    #endif
    
    #if os(Linux)
    public static let linuxDriverPath = findLinuxDriverPath()
    
    private static func findLinuxDriverPath() -> String {
        // Look in common installation locations
        let possiblePaths = [
            "/usr/local/bin/chromedriver",
            "/usr/bin/chromedriver"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        // Default to expecting it in PATH
        return "chromedriver"
    }
    #endif
}
