# HDR Build Configuration Behavior

## Overview

QizhKit uses an environment-based build configuration to conditionally enable HDR-aware color APIs. This document explains how the feature works, how to enable it, and what code paths are affected.

## Environment Variable

The package checks for the `QIZHKIT_ENABLE_HDR` environment variable at build time:

- **Variable name:** `QIZHKIT_ENABLE_HDR`
- **Valid values:** `1` or `true` (case-insensitive for `true`)
- **Default behavior:** HDR APIs are **disabled** when the variable is not set

### How to Enable

Set the environment variable before building:

```bash
# In Terminal (macOS)
export QIZHKIT_ENABLE_HDR=1
swift build

# Or inline
QIZHKIT_ENABLE_HDR=1 swift build
```

In Xcode, you can set the environment variable in your scheme's Run/Build settings.

## Compiler Define

When `QIZHKIT_ENABLE_HDR` is set to `1` or `true`, the package adds the following Swift compiler define:

```swift
.define("RESOLVED_HDR_AVAILABLE")
```

This define is applied to both the main `QizhKit` target and the `QizhKitTests` target.

## Affected Code Paths

The `RESOLVED_HDR_AVAILABLE` define controls access to HDR-aware SwiftUI APIs introduced in iOS 26 and macOS 26:

### `Color+brightness+luminance.swift`

The `Color.resolvedComponents(of:in:)` function uses the define to choose between:

1. **With `RESOLVED_HDR_AVAILABLE`:** Uses `Color.resolveHDR(in:)` when available (iOS 26+, macOS 26+), falling back to `Color.resolve(in:)` on earlier platforms.

2. **Without `RESOLVED_HDR_AVAILABLE`:** Always uses `Color.resolve(in:)` (the pre-HDR API).

```swift
#if RESOLVED_HDR_AVAILABLE
if #available(iOS 26.0, macOS 26.0, *) {
    color.resolveHDR(in: environment).resolvedComponents
} else {
    color.resolve(in: environment).resolvedComponents
}
#else
color.resolve(in: environment).resolvedComponents
#endif
```

### Additional HDR-Only Extensions

The following extensions are only compiled when `RESOLVED_HDR_AVAILABLE` is defined:

- `Color.ResolvedComponents.init(linear:Color.ResolvedHDR)` – Initializer from HDR-resolved color
- `Color.ResolvedHDR.resolvedComponents` – sRGB components from HDR-resolved color
- `Color.ResolvedHDR.linearResolvedComponents` – Linear-light components from HDR-resolved color

## Platform Requirements

HDR-aware APIs require:
- **iOS 26.0** or later
- **macOS 26.0** or later

On earlier platforms, the code gracefully falls back to the standard `Color.resolve(in:)` API even when `RESOLVED_HDR_AVAILABLE` is defined.

## Why Environment-Based Configuration?

This approach allows:

1. **SDK Compatibility:** Projects using older SDKs (before Xcode 26) can still build QizhKit without encountering unknown symbol errors for `Color.ResolvedHDR` and `Color.resolveHDR(in:)`.

2. **Opt-in HDR Support:** Developers who want HDR-aware color resolution can explicitly enable it when their toolchain supports the new APIs.

3. **Consistent Build Behavior:** The same codebase works across CI environments, local development setups, and production builds with different SDK versions.

## Implementation Details

The configuration is implemented in `Package.swift`:

```swift
import Foundation // ← for ProcessInfo

/// Decide if HDR APIs should be enabled for QizhKit.
let isHDREnabled: Bool = {
    if let value = ProcessInfo.processInfo.environment["QIZHKIT_ENABLE_HDR"] {
        return value == "1" || value.lowercased() == "true"
    }
    return false
}()

/// Base swift settings for QizhKit.
var qizhKitSwiftSettings: [SwiftSetting] = [
    // ... other settings
]

/// Add the define only when HDR is explicitly enabled.
if isHDREnabled {
    qizhKitSwiftSettings.append(.define("RESOLVED_HDR_AVAILABLE"))
}
```

---

**Related Files:**
- `Package.swift` (lines 5-28)
- `Sources/QizhKit/Extensions/Color+/Color+brightness+luminance.swift`
- `Tests/QizhKitTests/ColorBrightnessLuminanceTests.swift`
