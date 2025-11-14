# Extensions

The `Sources/QizhKit/Extensions` tree bundles hundreds of small helpers for SwiftUI, UIKit, Combine, and the standard library. This document highlights representative groups so you can navigate the catalog efficiently.

## Strings and text
- `String+validation.swift` centralizes validation patterns. `StringValidationExpression` exposes prebuilt email and YouTube regular expressions, plus `isValidEmail`, `isValidYouTubeCode`, and `isValidURL` helpers. The same file includes emoji detection utilities (`isSingleEmoji`, `containsEmoji`, etc.) and the `isJson` property that attempts to parse JSON or JSON5 before returning `true`.
- Other string files handle whitespace trimming, NBSP replacement, capitalizing, random generation, and custom string interpolation. These utilities make it trivial to build user-facing copy without sprinkling raw regular expressions across each feature.

## SwiftUI bindings and environment data
- Binding conversion helpers (see `Binding+convert.swift`) convert between `TimeInterval` and `Date`, combine separate date and time pickers into a single binding, and expose `.asOptional(default:)` wrappers that reinterpret zero/empty values as `nil` so forms can rely on optional state instead of sentinel defaults.
- `Binding+events.swift`, `Binding+toggle.swift`, and related files wire additional setters that emit callbacks or support toggling boolean bindings inline.
- Environment-specific extensions (for `ColorScheme`, `Layout`, `View`, and many more) are grouped under their matching folders so you can pick the modifiers relevant to your SwiftUI layout with minimal searching.

## Async utilities
- `Task+sleep.swift` introduces platform-aware sleep helpers that switch to the `.continuous` clock on iOS 16+ while falling back to nanosecond sleeps elsewhere. Having both `sleep(milliseconds:)` and `sleep(seconds:)` keeps concurrency code consistent across OS releases.
- Combine publishers, `DispatchQueue`, and `Notification` namespaces each have folders with short inline helpers for throttling, scheduling, and bridging to async sequences.

## Foundation and numeric helpers
- Extensions for `Date`, `Formatter`, `Measurement`, `Locale`, and `TimeInterval` are organized under folders named after the type they modify. Most files are only a few lines long, but together they provide conveniences such as ISO-8601 parsing, unit conversions, pointer math, and bridging between Swift numeric protocols.
