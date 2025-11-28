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
