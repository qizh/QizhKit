# QizhKit - Copilot Instructions

This document provides instructions for GitHub Copilot coding agent when working with the QizhKit repository.

## Repository Overview

QizhKit is a collection of Swift and SwiftUI tools and extensions targeting iOS, macOS, macCatalyst, and visionOS platforms. The project uses Swift 6.1+ and follows modern Swift concurrency patterns.

## Technology Stack

- **Language**: Swift 6.1+
- **Frameworks**: SwiftUI, UIKit, Combine
- **Package Manager**: Swift Package Manager (SPM)
- **Platforms**: iOS 17+, macOS 14+, macCatalyst 17+
- **Testing**: Swift Testing (`@Suite("Tests Group Name")` and `@Test("Test Name")`)

## Project Structure

```
QizhKit/
├── Sources/QizhKit/
│   ├── Components/         # Reusable SwiftUI components
│   ├── Extensions/         # Swift and SwiftUI extensions
│   ├── Structures/         # Data structures and models
│   ├── UI/                 # UI-related utilities
│   ├── UIKit/              # UIKit-specific extensions
│   ├── Third Party/        # Third-party code (with attribution)
│   ├── Ugly/               # Utilities that need refactoring
│   ├── Localizations/      # Localization resources
│   └── PrivacyInfo.xcprivacy
├── Tests/QizhKitTests/    # Test files
└── Package.swift          # SPM manifest
```

## Build and Test Commands

### Building the Package
```bash
swift build
```

### Running Tests
```bash
swift test
```

### Building for Specific Platform
```bash
# For iOS
swift build -Xswiftc "-sdk" -Xswiftc "`xcrun --sdk iphoneos --show-sdk-path`" -Xswiftc "-target" -Xswiftc "arm64-apple-ios17"

# For macOS
swift build -Xswiftc "-sdk" -Xswiftc "`xcrun --sdk macosx --show-sdk-path`"
```

## Code Style and Conventions

### Swift Code
- Use Swift 6.1+ language features
- Follow Swift API design guidelines
- Prefer value types (structs) over reference types (classes) when appropriate
- Use explicit access control modifiers
- Leverage Swift concurrency (async/await, actors) where appropriate
- Use `@MainActor` for UI-related code when needed

### SwiftUI Code
- Use declarative syntax
- Prefer view modifiers over wrapper views
- Extract complex views into separate components
- Use `@State`, `@Binding`, etc. appropriately
- Follow SwiftUI best practices for performance

### Documentation
- Add DocC-style documentation comments for all public APIs
- Include parameter descriptions, return values, and examples when relevant
- Use triple-slash (`///`) comments for documentation
- Update related `.md` files in the repository when adding major features
- **DO NOT** treat block comments (`/* ... */`) as documentation — these typically contain commented-out code, not documentation

### Testing
- Write unit tests for new functionality
- Follow existing test patterns in `Tests/QizhKitTests/`
- Ensure tests are deterministic and don't depend on external state
- Test edge cases and error conditions

## Dependencies

### Current Dependencies

The following dependencies are used (package name → product name):

- **swiftui-introspect** (26.0.0+) → `SwiftUIIntrospect`: For SwiftUI view introspection
- **Alamofire** (5.10.2+) → `Alamofire`: Networking
- **DeviceKit** (5.7.0+) → `DeviceKit`: Device information
- **BetterSafariView** (2.4.4+) → `BetterSafariView`: In-app Safari views
- **swift-collections** (1.3.0+) → `OrderedCollections`: Apple's ordered collection types
- **QizhMacroKit** (exactly 1.1.11) → `QizhMacroKit` and `QizhMacroKitClient`: Custom Swift macros made by the same author

### Updating Dependencies
- **DO NOT** update dependencies to versions with breaking changes without explicit permission
- When updating dependencies, check for breaking changes in the changelog
- If a breaking change is unavoidable, create an issue documenting the required code changes
- Prefer updating to the latest patch or minor version that maintains compatibility
- Always update `Package.resolved` when changing dependency versions
- Run tests after updating dependencies to ensure compatibility

## What You Should Do

### For Code Changes
1. **Review existing code patterns** before making changes
2. **Write tests** for new functionality
3. **Update documentation** (DocC comments and markdown files) when adding features
4. **Build and test** your changes before submitting
5. **Use existing libraries** when possible instead of reinventing solutions
6. **Follow the repository's existing code style** and patterns, prefer recently added or updated ones
7. **Add proper error handling** for edge cases
8. **Consider performance implications** especially for UI code

### For Documentation
1. Update DocC comments for all public APIs
2. Update or create `.md` files for major components
3. Update `README.md` when adding significant features
4. Include code examples in documentation where helpful

### For Bug Fixes
1. Understand the root cause before fixing
2. Add tests that reproduce the bug (if feasible)
3. Ensure the fix doesn't break existing functionality
4. Consider edge cases that might have similar issues

## What You Should NOT Do

### Code
- **DO NOT** remove or modify working code unless absolutely necessary
- **DO NOT** delete existing tests unless they are testing functionality being removed
- **DO NOT** update dependencies to versions with breaking changes without permission
- **DO NOT** commit secrets, API keys, or sensitive data
- **DO NOT** introduce security vulnerabilities
- **DO NOT** make changes to `.github/agents/` directory (these are agent configuration files)
- **DO NOT** modify `Package.resolved` unless you're intentionally updating dependencies

### Build Artifacts
- **DO NOT** commit build artifacts (`.build/`, `DerivedData/`)
- **DO NOT** commit user-specific files (`xcuserdata/`, `.DS_Store`)
- **DO NOT** commit IDE-specific files unless they are project-wide shared schemes

### Tests
- **DO NOT** disable or skip tests to make builds pass
- **DO NOT** remove test assertions without understanding why they exist
- **DO NOT** make tests pass by changing the expected values without understanding the change

## File and Directory Guidelines

### Files to Ignore
As per `.gitignore`:
- `.DS_Store`
- `.build/`
- `Packages/`
- `*.xcodeproj` (generated by Xcode)
- `xcuserdata/`
- `DerivedData/`
- `.swiftpm/xcode/xcuserdata/`

### Files to Keep in Source Control
- `Package.resolved` - for reproducible builds
- `.swiftpm/` - except user-specific data

## Special Directories

### `Sources/QizhKit/Off/`
This directory is excluded from builds (see `Package.swift`). It contains:
- Code that is temporarily disabled
- Experimental features not ready for production
- Deprecated code kept for reference → most common case

**DO NOT** move files into or out of this directory without understanding the implications.

### `Sources/QizhKit/Ugly/`
Contains utilities that work but need refactoring:
- Code that needs cleanup
- Quick fixes that should be improved
- Legacy patterns that should be modernized

When working with this code, prefer to refactor it if you have time, but don't break existing functionality.

### `Sources/QizhKit/Third Party/`
Contains third-party code with proper attribution:
- Always maintain attribution comments
- Check licenses before modifying
- Consider upstreaming improvements to original authors

## Privacy and Security

- The project includes `PrivacyInfo.xcprivacy` for App Privacy requirements
- Do not collect or transmit user data without proper disclosure
- Be mindful of privacy implications when adding new features
- Ensure all networking code properly handles sensitive data

## Localization

- Localization resources are in `Sources/QizhKit/Localizations/`
- Default localization is English (`en`)
- When adding user-facing strings, consider localization

### Languages to support
- `en` — English
- `de` — German
- `es` — Spanish
- `fr` — French
- `it` — Italian
- `pt-BR` — Brazilian Portuguese
- `pt-PT` — European Portuguese
- `ru` — Russian
- `uk` — Ukrainian

## CI/CD Considerations

- Ensure code builds on CI environments (may differ from local)
- Some dependencies may have platform-specific behavior
- Tests should be deterministic and not rely on network or file system
- Be aware that SwiftUI previews may not work in CI environments

## Getting Help

If you encounter issues or need clarification:
1. Check existing code for similar patterns
2. Review the repository's documentation and README
3. Look at test files for usage examples
4. Check dependency documentation for third-party libraries
5. Create an issue with a clear description of the problem

## Agent-Specific Notes

The repository has a custom agent configured in `.github/agents/qizh.agent.md` with specific personality and responsibilities. 

**Instruction Priority**: When the custom agent is active:
1. The custom agent's instructions in `.github/agents/qizh.agent.md` take precedence for code generation and review tasks
2. This file (`.github/copilot-instructions.md`) provides general repository context and conventions
3. Both sets of instructions are complementary - the agent instructions define behavior and personality, while this file documents repository structure and best practices

---

**Last Updated**: 2025-12-01
**Swift Version**: 6.1+
**Minimum Platforms**: iOS 17, macOS 14, macCatalyst 17
