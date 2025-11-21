# macOS CI Build Failures - Debug UI Utilities

## Overview

This document tracks the resolution of macOS CI build failures in debug UI utilities and AttributedString extensions. The failures were caused by iOS-specific APIs being used without platform guards.

## Issues Identified

### 1. LabeledValueView.swift

#### Issue 1.1: Missing AppKit import for macOS clipboard
- **Problem**: `UIPasteboard` was used directly without conditional compilation
- **Location**: Line 546
- **Error**: `UIPasteboard` is iOS-only

#### Issue 1.2: iOS-only contentShape kinds and hoverEffect
- **Problem**: `.contextMenuPreview` and `.hoverEffect` content shape kinds are iOS-only
- **Location**: Lines 501-502, 536-537
- **Error**: These APIs are not available on macOS

#### Issue 1.3: `.systemBackground` is iOS-only
- **Problem**: `.systemBackground` color is not available on macOS
- **Location**: Line 528
- **Error**: `systemBackground` is not a member of `ShapeStyle`

### 2. AttributedString+String.swift

#### Issue 2.1: UIColor-only foregroundColor helper
- **Problem**: `foregroundColor` extension only accepts `UIColor`, which doesn't exist on macOS
- **Location**: Line 19
- **Error**: `UIColor` is iOS-only, causing compilation failures on macOS

### 3. ValueView.swift

#### Issue 3.1: UIColor.secondaryLabel is iOS-only
- **Problem**: `.secondaryLabel` UIColor is iOS-only
- **Location**: Lines 163, 167, 170, 172, 174, 177, 180, 182, 184, 186, 187
- **Error**: `secondaryLabel` type property is unavailable on macOS

## Solutions Implemented

### 1. LabeledValueView.swift Fixes

#### 1.1 Import AppKit conditionally for macOS clipboard
Added conditional import at the top of the file:
```swift
#if canImport(AppKit)
import AppKit
#endif
```

#### 1.2 Guard iOS-only contentShape kinds and hoverEffect
Updated both `labelView()` and `valueViewBody()` to use base content shapes everywhere, with iOS-specific enhancements conditionally:
```swift
.contentShape([.interaction, .dragPreview], shape)
#if os(iOS)
.contentShape([.contextMenuPreview, .hoverEffect, .interaction, .dragPreview], shape)
.hoverEffect(.highlight)
#endif
```

#### 1.3 Replace `.systemBackground` with cross-platform background
Replaced with `.regularMaterial` which is available on both platforms:
```swift
.background(.regularMaterial, in: shape)
```

#### 1.4 Make pasteboard behavior platform-aware
Updated copy button to work on both platforms:
```swift
.button {
    #if canImport(UIKit)
    UIPasteboard.general.string = valueView.string
    #elseif canImport(AppKit)
    let pb = NSPasteboard.general
    pb.clearContents()
    pb.setString(valueView.string, forType: .string)
    #endif
}
```

### 2. AttributedString+String.swift Fixes

#### 2.1 Make `foregroundColor` helper cross-platform
Changed the primary implementation to use SwiftUI `Color` (cross-platform) and added a UIKit convenience overload:
```swift
extension AttributedString {
    /// Cross-platform helper using SwiftUI.Color
    @inlinable public func foregroundColor(_ color: Color) -> AttributedString {
        transformingAttributes(\.foregroundColor) { foregroundColor in
            foregroundColor.value = color
        }
    }

    #if canImport(UIKit)
    /// iOS convenience overload
    @inlinable public func foregroundColor(_ color: UIColor) -> AttributedString {
        foregroundColor(Color(uiColor: color))
    }
    #endif
}
```

### 3. ValueView.swift Fixes

#### 3.1 Add cross-platform "secondary label" color helper
Added a private helper property:
```swift
private var debugSecondaryLabelColor: Color {
    #if canImport(UIKit)
    Color(uiColor: .secondaryLabel)
    #elseif canImport(AppKit)
    Color(nsColor: .secondaryLabelColor)
    #else
    .secondary
    #endif
}
```

#### 3.2 Use the new helper in `attributedString`
Replaced all `.foregroundColor(.secondaryLabel)` calls with `.foregroundColor(debugSecondaryLabelColor)` to use the cross-platform helper.

## Tasks

- [x] Guard `hoverEffect` and `contextMenuPreview` usages in `LabeledValueView` so they are only compiled on iOS.
- [x] Replace `.systemBackground` in `LabeledValueView` with a cross-platform background style (`.regularMaterial`).
- [x] Make the pasteboard copy behavior in `LabeledValueView` work on both iOS (`UIPasteboard`) and macOS (`NSPasteboard`).
- [x] Make `AttributedString.foregroundColor` cross-platform (use `Color` and add an optional UIKit overload).
- [x] Replace `.secondaryLabel` usages in `ValueView.attributedString` with a cross-platform color abstraction.
- [ ] Ensure the Swift package builds cleanly on macOS in CI.

## Testing

The changes should be tested by:
1. Building the package on macOS: `swift build`
2. Building the package on iOS simulator
3. Verifying that the debug UI views still render correctly on both platforms
4. Testing clipboard functionality on both platforms

## References

- Original issue ref: `ef5a52bd0e407d71b04ff831d07e45e55f672545`
- Files modified:
  - `Sources/QizhKit/UI/Debug/LabeledValueView.swift`
  - `Sources/QizhKit/Extensions/AttributedString+/AttributedString+String.swift`
  - `Sources/QizhKit/UI/Debug/ValueView.swift`
## CI: macOS build failures in debug UI utilities (hoverEffect, UIColor, UIPasteboard, ShapeStyle.systemBackground)

The recent CI build has failed due to several compiler errors that are specific to macOS. Below is a summary of the errors found in the build log:

### Compiler Errors:
- **Use of iOS-only SwiftUI APIs:** `contextMenuPreview` and `hoverEffect` in `Sources/QizhKit/UI/Debug/LabeledValueView.swift` (lines 501-503) are unavailable on macOS.
- **Use of UIKit-only types:** `UIPasteboard` and `UIColor` in `Sources/QizhKit/UI/Debug/LabeledValueView.swift` (line 546) and `Sources/QizhKit/Extensions/AttributedString+/AttributedString+String.swift` (line 19).
- **Use of .systemBackground shape style:** This is referenced in `Sources/QizhKit/UI/Debug/LabeledValueView.swift` (line 528) and doesn't exist on macOS.
- **Incorrect use of .foregroundColor(.secondaryLabel):** In `Sources/QizhKit/UI/Debug/ValueView.swift` (line 163). This is treated as an optional Color and the `.secondaryLabel` case is missing on macOS.

These files appear to be debug-only UI helpers and could potentially be conditionally compiled using `#if canImport(UIKit)` or `#if os(iOS)` to prevent macOS CI failures. Alternatively, they can be updated to use AppKit-friendly APIs (such as `NSColor`, `NSPasteboard`, and macOS-compatible `ShapeStyle`).

It is important to note that the package builds cleanly in Xcode 26.x on my machine, indicating that the issue stems from the GitHub Actions workflow where some iOS-specific APIs are unavailable on the macOS target.

I would appreciate guidance on whether the desired fix is to:
(a) make these APIs cross-platform, or  
(b) exclude the iOS-only debug UI from the macOS CI job.
