# QizhKit - Copilot Instructions

## Project Overview

QizhKit is a collection of Swift and SwiftUI small tools and extensions. This is a Swift Package that targets iOS 17+, macOS 14+, macCatalyst 17+, and visionOS 1+.

## Language and Platform Requirements

- **Swift Version**: 6.1+ (Swift 6 language mode enabled)
- **Platforms**: iOS 17+, macOS 14+, macCatalyst 17+, visionOS 1+
- **Primary Frameworks**: Foundation, SwiftUI, UIKit (where applicable)

## Code Style and Conventions

### General Swift Guidelines

- Follow Swift 6 strict concurrency model
- Use `public` access level for library APIs
- Use `@inlinable` for performance-critical small functions
- Prefer value types (structs) over reference types when appropriate
- Mark types as `Sendable` when they need to cross concurrency boundaries

### Naming Conventions

- Use clear, descriptive names that communicate intent
- Extension files follow pattern: `TypeName+functionality.swift` (e.g., `String+email.swift`, `View+onAppear.swift`)
- Group related extensions in dedicated directories (e.g., `Extensions/String+/`, `Extensions/ViewModifiers/`)

### File Headers

Include standard file headers with creation date and copyright:

```swift
//
//  FileName.swift
//  QizhKit
//
//  Created by [Author Name] on [Date].
//  Copyright © [Year] Serhii Shevchenko. All rights reserved.
//
```

### Code Organization

- Use `// MARK: -` comments to organize code sections
- Group related functionality together
- Keep extensions focused on single responsibilities
- Store third-party code in `Third Party/` directory
- Place experimental or disabled code in `Off/` directory (excluded from build)

### SwiftUI Patterns

- Use `@ViewBuilder` for flexible view composition
- Implement custom `ViewModifier` types for reusable view transformations
- Use `@inlinable` for view builder functions to improve compile-time optimization
- Prefer composition over inheritance
- Use `@State`, `@Binding`, and other property wrappers appropriately

### Code Quality

- Write clean, self-documenting code
- Use guard statements for early returns
- Prefer `if let` and guard-let for optional unwrapping
- Use trailing closures where appropriate
- Chain method calls for better readability when suitable

## Documentation Requirements

### DocC Documentation

- Document all public APIs with DocC-style comments
- Use triple-slash (`///`) comments for documentation
- Include parameter descriptions using `- Parameters:`
- Document return values when not obvious
- Provide usage examples for complex APIs

Example:
```swift
/// Initializes a local copy storage location.
///
/// - Parameters:
///   - path: Slash separated path or just a folder name.
///   For example, `"cache"` or `"caches/requests"`.
///   - name: File name. Model class name by default.
///   - type: File type. json by default.
public init(
    path: String,
    name: String = "\(Model.self)",
    type: CommonFileType = .json
) throws {
    // Implementation
}
```

## Testing Requirements

### Test Framework

- Use Swift Testing framework (not XCTest)
- Import with: `import Testing`
- Use `@Suite` for test organization
- Use `@Test` for individual test methods
- Use `#expect` for assertions (not XCTAssert)

Example:
```swift
import Testing
import QizhKit

@Suite("String extension properties tests")
struct TestStringProperties {
    @Test func testIsJson() async throws {
        #expect("{id: 2}".isJson)
        #expect("   {id: 2} ".isJson)
        #expect(!"Try to use {id: 2}".isJson)
    }
}
```

### Test Coverage

- Write tests for all new public APIs
- Test edge cases and error conditions
- Use async/await in tests when testing async code
- Keep tests focused and independent

## Dependencies

Current dependencies:
- SwiftUI-Introspect (26.0.0+)
- Alamofire (5.10.2+)
- DeviceKit (5.7.0+)
- BetterSafariView (qizh fork, 2.4.4+)
- swift-collections (1.3.0+)
- QizhMacroKit (exact: 1.1.11)

### Dependency Updates

- **IMPORTANT**: Never update dependencies to versions with breaking changes without explicit approval
- Update to the latest version without breaking changes when possible
- If breaking changes are needed, create an issue to discuss the migration
- Test all functionality after dependency updates

## Build and Test Commands

### Building
```bash
swift build
```

### Running Tests
```bash
swift test
```

### Note on CI Environment
Tests may not run successfully in all environments (e.g., Linux) due to SwiftUI and platform-specific dependencies. This is expected.

## Resources and Localization

- Default localization: English (`en`)
- Localization files stored in `Sources/QizhKit/Localizations/`
- Privacy manifest: `Sources/QizhKit/PrivacyInfo.xcprivacy`
- Process resources with `.process()` in Package.swift

## Architecture Patterns

### Extensions Pattern
- Group extensions by functionality in separate files
- Use dedicated directories for related extensions
- Keep extensions focused on single concerns

### Error Handling
- Define custom error types conforming to `LocalizedError`
- Provide descriptive error messages
- Use throwing functions where errors are expected

### Async/Await
- Prefer async/await over completion handlers
- Use `Task` for concurrent work
- Specify `TaskPriority` when appropriate
- Use `@Sendable` closures when crossing concurrency boundaries

## Best Practices

1. **Minimal Changes**: Make the smallest possible modifications to achieve goals
2. **Preserve Working Code**: Don't remove or modify working code unless necessary
3. **Test Early**: Build and test changes as early as possible
4. **Documentation**: Update documentation when adding/modifying public APIs
5. **Type Safety**: Leverage Swift's type system for compile-time safety
6. **Performance**: Consider using `@inlinable` for small, frequently-called functions
7. **Concurrency**: Follow Swift 6 concurrency best practices

## Common Utilities

The library provides various utilities including:
- String extensions (email handling, validation, formatting)
- SwiftUI view modifiers and helpers
- Caching mechanisms (LocalCopy)
- Collection utilities
- Date and time helpers
- Networking helpers (with Alamofire)

## Special Considerations

- Code in `Off/` directory is excluded from builds
- SwiftUI is the primary UI framework; UIKit used only when necessary
- Support for multiple Apple platforms (iOS, macOS, visionOS, Catalyst)
- Consider platform availability when using new APIs
