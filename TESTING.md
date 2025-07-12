# Testing Framework Documentation

This document provides comprehensive information about Ariadne's testing framework, including how to run tests, write new tests, and understand the testing infrastructure.

## Table of Contents

- [Overview](#overview)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Writing Tests](#writing-tests)
- [Test Utilities](#test-utilities)
- [Performance Testing](#performance-testing)
- [CI/CD Integration](#cicd-integration)
- [Coverage Reports](#coverage-reports)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

Ariadne uses Swift Testing framework for its test suite, providing comprehensive coverage across multiple test categories:

- **Unit Tests**: Test individual components and functions
- **Integration Tests**: Test interactions between components and real browser automation
- **Performance Tests**: Measure and validate performance characteristics
- **End-to-End Tests**: Test complete workflows and user scenarios

## Test Structure

The test suite is organized into several key files:

```
Tests/AriadneTests/
├── AriadneTests.swift          # Basic framework tests
├── ChromeDriverTests.swift     # Chrome-specific functionality tests
├── CoreWebDriverTests.swift    # Core WebDriver functionality tests
├── Phase3IntegrationTests.swift # Advanced features integration tests
├── PerformanceTests.swift      # Performance and benchmarking tests
└── TestUtilities.swift         # Test helpers and utilities
```

### Test Categories

#### 1. Core WebDriver Tests (`CoreWebDriverTests.swift`)
Tests fundamental WebDriver operations:
- Navigation (navigate, back, forward, refresh)
- Element finding (by ID, class, CSS selector, XPath)
- Window management (resize, position, maximize)
- JavaScript execution
- Cookie management
- Screenshot functionality

#### 2. Chrome Driver Tests (`ChromeDriverTests.swift`)
Tests Chrome-specific functionality:
- ChromeDriver creation and lifecycle
- Chrome capabilities and options
- Advanced Chrome features
- Browser preferences and configurations

#### 3. Integration Tests (`Phase3IntegrationTests.swift`)
Tests advanced features from Phase 3:
- Performance monitoring integration
- Browser health monitoring
- Advanced element interactions
- Logging infrastructure
- Error reporting
- Browser pool management
- Platform optimizations

#### 4. Performance Tests (`PerformanceTests.swift`)
Measures and validates performance:
- Driver startup time
- Navigation performance
- Element finding speed
- Memory usage and leak detection
- Concurrent operation performance
- Load testing and stress testing

## Running Tests

### Prerequisites

Before running tests, ensure you have:

1. **Swift 5.8+** installed
2. **ChromeDriver** available in your PATH
3. **Google Chrome** browser installed

Install ChromeDriver:
```bash
# macOS (using Homebrew)
brew install chromedriver

# Ubuntu/Debian
sudo apt-get install chromium-chromedriver

# Manual installation
# Download from https://chromedriver.chromium.org/
```

### Basic Test Execution

#### Run All Tests
```bash
swift test
```

#### Run Specific Test Suites
```bash
# Run only core WebDriver tests
swift test --filter "CoreWebDriverTests"

# Run only performance tests
swift test --filter "PerformanceTests"

# Run only integration tests
swift test --filter "Phase3IntegrationTests"
```

#### Run Individual Tests
```bash
# Run a specific test method
swift test --filter "testNavigationPerformance"
```

### Using the Test Runner Script

The automated test runner provides advanced options:

```bash
# Run all tests with coverage
./scripts/test-runner.sh --type all --coverage

# Run only unit tests
./scripts/test-runner.sh --type unit

# Run performance tests in parallel
./scripts/test-runner.sh --type performance --parallel

# Run tests with GUI (not headless)
./scripts/test-runner.sh --gui

# Verbose output for debugging
./scripts/test-runner.sh --verbose
```

#### Test Runner Options

| Option | Description | Default |
|--------|-------------|---------|
| `--type` | Test type: all, unit, integration, performance | all |
| `--environment` | Environment: local, ci, docker | local |
| `--parallel` | Run tests in parallel | false |
| `--coverage` | Generate coverage report | false |
| `--verbose` | Verbose output | false |
| `--gui` | Run with GUI (not headless) | false |
| `--output` | Output directory | test-results |
| `--timeout` | Test timeout in seconds | 300 |

### Test Configuration

#### Environment Variables

Control test behavior with environment variables:

```bash
# Enable headless mode (default for CI)
export ARIADNE_HEADLESS=true

# Set test timeout
export ARIADNE_TEST_TIMEOUT=600

# Enable performance mode
export ARIADNE_PERFORMANCE_MODE=true

# Enable verbose logging
export ARIADNE_VERBOSE=true
```

#### Test Configurations

Use predefined test configurations:

```swift
// Unit test configuration
let config = TestConfiguration.unitTest

// Integration test configuration  
let config = TestConfiguration.integrationTest

// Performance test configuration
let config = TestConfiguration.performanceTest

// Custom configuration
let config = TestConfiguration(
    headless: true,
    timeout: 30.0,
    windowSize: (1024, 768),
    additionalArguments: ["--no-sandbox"]
)
```

## Writing Tests

### Test Structure

Use Swift Testing framework syntax:

```swift
import Testing
import WebDriver
@testable import Ariadne

@Suite("My Test Suite") 
final class MyTests {
    
    @Test func myTestMethod() throws {
        // Test implementation
        #expect(condition == expectedValue)
    }
    
    @Test func asyncTestMethod() async throws {
        // Async test implementation
        let result = await someAsyncOperation()
        #expect(result.isSuccess)
    }
}
```

### Using Test Utilities

Leverage the `TestUtilities` class for common operations:

```swift
let testUtils = TestUtilities.shared

// Create test driver
let driver = testUtils.createTestDriver(headless: true)
defer { testUtils.cleanupTestDriver(driver) }

// Create test HTML file
let testFileURL = testUtils.createTestHTMLFile()
defer { testUtils.cleanupTestFiles([testFileURL.path]) }

// Create test data
let formData = testUtils.generateTestFormData()
let testFile = testUtils.createTestFile()

// Performance measurement
let executionTime = testUtils.measureTime {
    // Code to measure
}

// Assertions
#expect(testUtils.assertElementVisible(driver: driver, locator: .id("button")))
#expect(testUtils.assertTitle(driver: driver, expectedTitle: "Test Page"))
```

### Writing Integration Tests

Integration tests should follow this pattern:

```swift
@Test func myIntegrationTest() async throws {
    // Create driver
    let driver = testUtils.createTestDriver()
    guard let driver = driver else {
        // Skip test if ChromeDriver not available
        return
    }
    
    defer { testUtils.cleanupTestDriver(driver) }
    
    // Create test resources
    guard let testFileURL = testUtils.createTestHTMLFile() else {
        throw TestUtilityError.fileCreationFailed("Could not create test HTML file")
    }
    
    defer { testUtils.cleanupTestFiles([testFileURL.path]) }
    
    // Test implementation
    try driver.navigate(to: testFileURL)
    
    // Use advanced features
    let interactions = driver.createAdvancedInteractions()
    let monitor = driver.createPerformanceMonitor()
    
    // Assertions
    #expect(driver.title == "Test Page")
}
```

### Writing Performance Tests

Performance tests should measure specific metrics:

```swift
@Test func performanceTestExample() async throws {
    let config = TestConfiguration.performanceTest
    let driver = testUtils.createTestDriver(capabilities: config.createCapabilities())
    guard let driver = driver else { return }
    
    defer { testUtils.cleanupTestDriver(driver) }
    
    // Measure operation time
    let operationTime = testUtils.measureTime {
        try? driver.navigate(to: "https://example.com")
    }
    
    // Assert performance threshold
    #expect(operationTime < 2.0) // Should complete within 2 seconds
    
    // Memory usage check
    let memoryUsage = testUtils.getCurrentMemoryUsage()
    #expect(memoryUsage < 100 * 1024 * 1024) // Should use less than 100MB
}
```

## Test Utilities

The `TestUtilities` class provides helpful methods for testing:

### Driver Management
- `createTestDriver()` - Create test ChromeDriver instance
- `cleanupTestDriver()` - Clean up driver resources
- `isChromDriverAvailable()` - Check if ChromeDriver is available

### Test Data Creation
- `createTestHTML()` - Generate test HTML content
- `createTestHTMLFile()` - Create temporary HTML file
- `generateTestFormData()` - Generate form test data
- `createTestFile()` - Create test file for uploads
- `createTestImage()` - Create test image file

### Assertions
- `assertElementVisible()` - Assert element is visible
- `assertElementClickable()` - Assert element is clickable
- `assertTextPresent()` - Assert text is present on page
- `assertTitle()` - Assert page title
- `assertURLContains()` - Assert URL contains text

### Performance Utilities
- `measureTime()` - Measure execution time
- `measureTimeAsync()` - Measure async execution time
- `getCurrentMemoryUsage()` - Get current memory usage

### Wait Utilities
- `waitFor()` - Wait for condition with timeout
- `waitForOrThrow()` - Wait for condition or throw

## Performance Testing

### Performance Test Categories

1. **Startup Performance**: Driver creation and initialization time
2. **Navigation Performance**: Page loading and navigation speed
3. **Element Performance**: Element finding and interaction speed
4. **Memory Performance**: Memory usage and leak detection
5. **Concurrent Performance**: Multi-driver and parallel operation performance

### Performance Metrics

Tests measure various performance metrics:

- **Execution Time**: How long operations take
- **Memory Usage**: Memory consumption during operations
- **Throughput**: Operations per second
- **Latency**: Response time for individual operations

### Performance Assertions

```swift
// Time-based assertions
#expect(operationTime < 1.0) // Under 1 second

// Memory-based assertions  
#expect(memoryIncrease < 50 * 1024 * 1024) // Under 50MB increase

// Throughput assertions
#expect(operationsPerSecond > 10) // At least 10 ops/sec
```

### Performance Configuration

Use `PerformanceTestConfiguration` for consistent performance testing:

```swift
let perfConfig = PerformanceTestConfiguration.heavy
let results = runPerformanceTest(config: perfConfig) { driver in
    // Performance test code
}

print(results.description)
```

## CI/CD Integration

### GitHub Actions Workflows

The project includes several CI/CD workflows:

#### 1. Main CI Workflow (`.github/workflows/ci.yml`)
- Runs on push/PR to main branches
- Tests on Ubuntu and macOS
- Generates code coverage
- Builds release artifacts

#### 2. Release Workflow (`.github/workflows/release.yml`)
- Triggered on version tags
- Runs comprehensive tests
- Creates GitHub releases
- Publishes documentation

#### 3. Nightly Testing (`.github/workflows/nightly.yml`)
- Runs extensive test suites nightly
- Performance and stress testing
- Compatibility testing across platforms
- Security scanning

### CI Environment Configuration

Tests automatically adapt to CI environments:

```bash
# CI-specific environment variables
export ARIADNE_CI_MODE=true
export ARIADNE_HEADLESS=true
export CHROME_BIN=/usr/bin/google-chrome-stable
```

### Test Parallelization

CI workflows use parallel test execution:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest]
    test-type: [unit, integration, performance]
```

## Coverage Reports

### Generating Coverage

Generate coverage reports using the coverage script:

```bash
# Generate comprehensive coverage report
./scripts/coverage-report.sh

# Or use test runner with coverage
./scripts/test-runner.sh --coverage
```

### Coverage Report Types

1. **LCOV Format**: For CI integration and external tools
2. **HTML Report**: Interactive coverage report
3. **JSON Format**: Machine-readable coverage data
4. **Summary Report**: Text-based coverage summary

### Coverage Thresholds

Project coverage targets:
- **Overall Coverage**: 80%
- **New Code Coverage**: 70%
- **Critical Paths**: 90%

### Coverage Configuration

Coverage settings in `codecov.yml`:

```yaml
coverage:
  status:
    project:
      default:
        target: 80%
    patch:
      default:
        target: 70%
```

## Best Practices

### Test Organization

1. **Group Related Tests**: Use `@Suite` to group related test methods
2. **Descriptive Names**: Use clear, descriptive test method names
3. **Single Responsibility**: Each test should test one specific behavior
4. **Test Independence**: Tests should not depend on each other

### Resource Management

1. **Clean Up Resources**: Always clean up drivers, files, and other resources
2. **Use Defer**: Use `defer` statements for cleanup
3. **Skip When Unavailable**: Skip tests when required resources aren't available

```swift
@Test func myTest() throws {
    let driver = testUtils.createTestDriver()
    guard let driver = driver else {
        // Skip test if ChromeDriver not available
        return
    }
    
    defer { testUtils.cleanupTestDriver(driver) }
    
    // Test implementation
}
```

### Error Handling

1. **Graceful Degradation**: Handle missing dependencies gracefully
2. **Meaningful Messages**: Provide clear error messages
3. **Expected Failures**: Use appropriate expectations for error conditions

### Performance Testing

1. **Consistent Environment**: Use consistent test environments
2. **Warm-up Runs**: Include warm-up iterations for performance tests
3. **Statistical Significance**: Run multiple iterations for reliable results
4. **Resource Monitoring**: Monitor memory and CPU usage

### Documentation

1. **Document Test Purpose**: Explain what each test validates
2. **Document Setup Requirements**: List any special setup needed
3. **Document Known Issues**: Note any known limitations or issues

## Troubleshooting

### Common Issues

#### ChromeDriver Not Found
```
Error: ChromeDriver not found
```

**Solution**:
```bash
# Install ChromeDriver
brew install chromedriver  # macOS
# or download from https://chromedriver.chromium.org/
```

#### Permission Denied
```
Error: Permission denied when executing chromedriver
```

**Solution**:
```bash
chmod +x /usr/local/bin/chromedriver
```

#### Chrome Not Found
```
Error: Chrome browser not found
```

**Solution**:
```bash
# Install Chrome
# macOS: Download from https://www.google.com/chrome/
# Ubuntu: sudo apt-get install google-chrome-stable
```

#### Tests Timeout
```
Error: Test execution timeout
```

**Solution**:
```bash
# Increase timeout
export ARIADNE_TEST_TIMEOUT=600
# or use test runner
./scripts/test-runner.sh --timeout 600
```

#### Memory Issues
```
Error: Out of memory during tests
```

**Solution**:
```bash
# Run tests sequentially
swift test --parallel-testing-enabled=false

# Or reduce concurrent operations
export ARIADNE_MAX_CONCURRENT=2
```

### Debug Mode

Enable debug mode for detailed logging:

```bash
export ARIADNE_DEBUG=true
export ARIADNE_VERBOSE=true
swift test --verbose
```

### Performance Issues

If tests are running slowly:

1. **Check System Resources**: Ensure adequate CPU and memory
2. **Use Headless Mode**: Run tests in headless mode
3. **Reduce Parallelism**: Decrease concurrent test execution
4. **Check Network**: Ensure stable network connection

### CI/CD Issues

For CI/CD pipeline issues:

1. **Check Dependencies**: Ensure all dependencies are installed
2. **Environment Variables**: Verify environment variables are set
3. **Permissions**: Check file and execution permissions
4. **Resource Limits**: Verify CI resource limits

### Getting Help

If you encounter issues not covered here:

1. **Check Logs**: Review test logs in the output directory
2. **Run Quality Check**: Use `./scripts/quality-check.sh`
3. **Check Documentation**: Review CLAUDE.md for project-specific guidance
4. **File Issues**: Report issues on the project repository

## Continuous Improvement

The testing framework is continuously improved:

1. **Regular Updates**: Test framework is updated with new features
2. **Performance Optimization**: Regular performance analysis and optimization
3. **Coverage Improvement**: Ongoing efforts to increase test coverage
4. **Best Practice Updates**: Testing practices updated based on learnings

For the latest information and updates, check the project's GitHub repository and documentation.