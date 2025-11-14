# UI catalog

QizhKit ships its own SwiftUI view catalog that mixes diagnostic utilities with production-ready building blocks. The folder layout reflects areas of concern so you can pull in only what you need.

## Debugging helpers
`UI/Debug/LabeledValueView.swift` defines environment keys for controlling how `LabeledValueView` instances truncate labels, wrap text, and split labels into columns via the reusable `LabeledColumnsLayout`. The layout tracks label widths, enforces a maximum label fraction, and lets you toggle multiline support per view hierarchy.

## Performance primitives
`UI/Performance/LazyView.swift` delays expensive view construction by wrapping bodies in a small `LazyView` container. The extension on `View` adds a `.lazy()` modifier so navigation stacks or tab switches only render their contents when needed.

## Visual effects
`UI/VisualEffects/VisualEffects.swift` bridges UIKit blur and vibrancy effects back into SwiftUI. It offers defaults for `UIBlurEffect.Style` based on the current color scheme, a `VisualEffectView` wrapper, and higher-level `BlurredBackgroundView`/`VibrantOnBlurredBackground` types for building frosted overlays.

## QR and progress views
`UI/Views/QRCodeImage.swift` uses CoreImage filters to generate `UIImage` QR codes and exposes them as SwiftUI `View`s with nearest-neighbor interpolation so the code stays sharp regardless of device scale.

## Web experiences
`UI/Web` holds three tiers of Safari integration: the `CooktourSafariViewController` host for embedding `SFSafariViewController` as a child, the SwiftUI-powered `SafariButton` that falls back to `BetterSafariView` when universal links fail, and supporting screens such as `WebpageScreen` and `WebView`. Each component accepts tint overrides, custom titles, and multiple presentation styles (push, sheet, or fullscreen cover).
