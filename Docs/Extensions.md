# Extensions

The `Sources/QizhKit/Extensions` tree bundles hundreds of small helpers for SwiftUI, UIKit, Combine, and the standard library. This document highlights representative groups so you can navigate the catalog efficiently.

*Newest stuff first, because who reads to the end anyway?* 😏

## Recent additions ✨

### Observable bindings
- `Observable+binding.swift` adds `binding(for:)` to any `@Observable` object, creating `Binding<Value>` without boilerplate. Finally, a one-liner that works.

### Cross-platform system backgrounds
- `ShapeStyle+SystemBackground.swift` provides `.systemBackground`, `.secondarySystemBackground`, and `.tertiarySystemBackground` that adapt to iOS/macOS/Catalyst automatically. No more `#if canImport(UIKit)` gymnastics in your view code.

### Range utilities
- `Range+clamp.swift` adds `ClosedRange.clamp(_:)` so you can write `(0.0...1.0).clamp(value)` instead of that min/max dance.

### InlineArray extensions
- `InlineArray+sugar.swift` gives Swift 6.2's `InlineArray` conformances to `Equatable`, `Hashable`, a `map` function, and an `asCollection()` bridge. Future-proofing for iOS 26+.

### asText() helpers
- `Text+from.swift` has expanded `asText()` methods for `String`, `LocalizedStringResource`, and `Optional<LocalizedStringResource>`. Plus `Text + Text?` operators and `[Text].joined(separator:)`.

### Bool output extensions
- `Bool+output.swift` now includes `asIntSign` (returns `1` for `true`, `-1` for `false`).

### CGFloat helpers
- `CG+common.swift` adds `CGFloat * CGPoint` operators and more geometry shortcuts.
- `TimeInterval+as.swift` now has a `cg: CGFloat` computed property.

### Shape/Animation utilities
- `Shape+sugar.swift` adds `AnimatableTrio`, `AnimatableQuartet`, `AnimatableCGFloatPair`, and `AnimatableCGFloatQuartet` typealiases for complex animations.

## Strings and text
- `String+validation.swift` centralizes validation patterns. `StringValidationExpression` exposes prebuilt email and YouTube regular expressions, plus `isValidEmail`, `isValidYouTubeCode`, and `isValidURL` helpers. The same file includes emoji detection utilities (`isSingleEmoji`, `containsEmoji`, etc.) and the `isJson` property that attempts to parse JSON or JSON5 before returning `true`.
- `String+asTreeBranches.swift` produces visual tree representations of nested data—great for debugging hierarchical structures.
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

<details>
<summary>🦕 Legacy extensions (older, but still kicking)</summary>

- Character set extensions
- Coding error descriptions
- Collection utilities (chunked, cycle, random sampling)
- Locale shortcuts
- Various UIKit bridges

*These still work but aren't the latest and greatest.*

</details>
