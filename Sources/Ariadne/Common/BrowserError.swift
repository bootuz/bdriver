//
//  BrowserError.swift
//  Ariadne
//
//  Created by Астемир Бозиев on 04.03.2025.
//


import Foundation

public enum BrowserError: Error {
    case noWindowHandleFound
    case waitTimeout(message: String?)
    case waitConditionFailed(message: String?, cause: Error)
    case driverStartFailed(message: String)
}
