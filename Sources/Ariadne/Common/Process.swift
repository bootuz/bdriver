//
//  ChromeProcess.swift
//  Ariadne
//
//  Created by Астемир Бозиев on 04.03.2025.
//

import Foundation
import WebDriver

#if os(macOS)
// On macOS, we can use the built-in Process class
public typealias DriverProcessManager = Foundation.Process
#elseif os(Linux)
// TODO: - Implement Linux process
#elseif os(Windows)
public typealias DriverProcessManager = Win32ProcessTree
#endif
