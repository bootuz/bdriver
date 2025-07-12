# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Workflow

### General Workflow for Code Changes
- First think through the problem, read the codebase for relevant files, and write a plan to tasks/todo.md.
- The plan should have a list of todo items that you can check off as you complete them
- Before you begin working, check in with me and I will verify the plan.
- Then, begin working on the todo items, marking them as complete as you go.
- Give a high level explanation of what changes you made at every step.
- Make every task and code change as simple as possible. We want to avoid making any massive or complex changes. Every change should impact as little code as possible. Everything is about simplicity.
- Finally, add a review section to the todo.md file with a summary of the changes you made and any other relevant information.

## Project Overview

Ariadne is a Swift WebDriver client library that provides a native Swift interface for browser automation. It wraps the swift-webdriver library to provide a more convenient API for Chrome browser automation.

## Build Commands

### Basic Operations
- Build the project: `swift build`
- Run tests: `swift test`
- Build for release: `swift build -c release`

### Testing
- Run all tests: `swift test`
- Run specific test suite: `swift test --filter "ChromiumDriverTests"`
- The project uses Swift Testing framework (not XCTest) for newer tests

## Architecture Overview

### Core Components

**Main Entry Point (`Ariadne.swift`)**
- Factory methods for creating ChromeDriver instances
- `Ariadne.chrome()` - Creates driver with default settings
- `Ariadne.chrome(capabilities:)` - Creates driver with custom capabilities
- `Ariadne.attachToChrome()` - Attaches to existing driver instance

**Driver Layer**
- `BaseDriver` - Base WebDriver implementation handling HTTP communication
- `ChromeDriver` - Chrome-specific driver implementation
- `WebDriverProtocol` - Core protocol for WebDriver functionality

**Service Management**
- `DriverService` protocol - Manages driver process lifecycle
- `DefaultDriverService` - Default implementation for process management
- `ChromeDriverService` - Chrome-specific service implementation
- `BrowserService` - Extended service protocol with browser capabilities

**Process Management**
- `DriverProcessManager` - Platform-specific process management
- Platform-specific implementations (macOS uses Foundation.Process)
- Automatic ChromeDriver executable path detection via `ChromePaths`

### Key Design Patterns

**Service-Driver Separation**: Services manage driver processes, drivers handle WebDriver communication
**Protocol-Oriented**: Heavy use of protocols for abstraction (`WebDriverProtocol`, `DriverService`, `BrowserService`)
**Platform Abstraction**: Conditional compilation for different operating systems
**Factory Pattern**: Main `Ariadne` class provides factory methods for driver creation

### Dependencies

- **swift-webdriver**: Core WebDriver protocol implementation from The Browser Company
- **WebDriver**: Main import for WebDriver functionality
- **Foundation**: For process management and system operations

### Testing Structure

- `AriadneTests` - Basic integration tests (currently commented out)
- `ChromiumDriverTests` - Chrome-specific driver tests using Swift Testing
- Tests require ChromeDriver binary to be available locally

### Platform Support

- **macOS**: Full support with automatic ChromeDriver path detection
- **Linux**: Basic support (process management TODO)
- **Windows**: Planned support with Win32ProcessTree

## Development Guidelines

### ChromeDriver Setup
Tests and development require ChromeDriver binary. The library automatically searches common paths:
- macOS: `/usr/local/bin/chromedriver`, `/usr/bin/chromedriver`, `/opt/homebrew/bin/chromedriver`
- Custom paths can be specified in service initialization

### Error Handling
- `DriverError` enum provides specific error types for driver-related failures
- Service lifecycle errors are handled with proper cleanup in deinit
- WebDriver communication errors are passed through from swift-webdriver

### Code Organization
- `Chrome/` - Chrome-specific implementations
- `Common/` - Shared browser abstractions and utilities
- Platform-specific code uses conditional compilation (`#if os(macOS)`)
