# UI catalog

QizhKit ships its own SwiftUI view catalog that mixes diagnostic utilities with production-ready building blocks. The folder layout reflects areas of concern so you can pull in only what you need.

*The good stuff first, the "it works, don't touch it" stuff later.* 🎨

## Recent enhancements ✨

### LabeledValueView gets serious upgrades
`UI/Debug/LabeledValueView.swift` has seen major improvements:

- **LabeledColumnsLayout** – A proper layout that tracks label widths, enforces maximum label fractions, and prevents nested column layouts from fighting each other.
- **New environment modifiers:**
  - `.setLabeledView(lengthLimit:)` – Max character limit for values
  - `.setLabeledView(allowMultiline:)` – Toggle line wrapping
  - `.setLabeledView(isInitiallyMultiline:)` – Default multiline state
  - `.setLabeledView(maxValueWidth:)` – Constrain value column width  
  - `.setLabeledView(isInColumnLayout:)` – Prevent nested layouts
  - `.setLabeledView(maxLabelFraction:)` – Control label width proportion (default 0.45)
  - `.setLabeledView(labelAsSentence:)` – Auto sentence-case conversion for labels
- **Collection support** – `labeledViews(label:)` now works cleanly with `Dictionary`, `Set`, `OrderedDictionary`, and generic collections without extra spacing issues.
- **Share button** – Values can now include a share button for easy copying.

### Cross-platform backgrounds
`UI/Debug/ShapeStyle+SystemBackground.swift` provides system background colors that work across iOS, macOS, and Catalyst without conditional compilation in your view code.

## Debugging helpers
`LabeledValueView` and friends let you quickly display key-value pairs with proper alignment. The `LabeledViews` container applies the column layout automatically and sets up the environment correctly for nested views.

```swift
LabeledViews {
    LabeledValueView("User ID", user.id)
    LabeledValueView("Email", user.email)
    LabeledValueView("Very Long Property Name", user.somethingVerbose)
}
.setLabeledView(maxLabelFraction: 0.4)
.setLabeledView(allowMultiline: true)
```

## Performance primitives
`UI/Performance/LazyView.swift` delays expensive view construction by wrapping bodies in a small `LazyView` container. The extension on `View` adds a `.lazy()` modifier so navigation stacks or tab switches only render their contents when needed. *Because why compute things before you absolutely have to?*

## Visual effects
`UI/VisualEffects/VisualEffects.swift` bridges UIKit blur and vibrancy effects back into SwiftUI. It offers defaults for `UIBlurEffect.Style` based on the current color scheme, a `VisualEffectView` wrapper, and higher-level `BlurredBackgroundView`/`VibrantOnBlurredBackground` types for building frosted overlays.

## QR and progress views
`UI/Views/QRCodeImage.swift` uses CoreImage filters to generate `UIImage` QR codes and exposes them as SwiftUI `View`s with nearest-neighbor interpolation so the code stays sharp regardless of device scale.

## Web experiences
`UI/Web` holds three tiers of Safari integration: the `CooktourSafariViewController` host for embedding `SFSafariViewController` as a child, the SwiftUI-powered `SafariButton` that falls back to `BetterSafariView` when universal links fail, and supporting screens such as `WebpageScreen` and `WebView`. Each component accepts tint overrides, custom titles, and multiple presentation styles (push, sheet, or fullscreen cover).

<details>
<summary>🦕 Other UI bits (functional but less glamorous)</summary>

- Rotated view wrappers (use `RotatedLayout` now, not the old `Rotated`)
- Various placeholder helpers
- Border modifiers with improved Color handling

*These work but aren't winning any awards.*

</details>
