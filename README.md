# QizhKit

A Swift 6 toolkit that bundles SwiftUI building blocks, backend-facing models, localization catalogs, and a deep set of extensions for day-to-day app development. The package targets iOS 17+, macOS 14+, and macCatalyst 17+ while shipping as a single library product named `QizhKit`. *Yes, another "one package to rule them all" situation—because who doesn't love a monolith?* 😏

## Overview
- **Bleeding-edge Swift toolchain.** `Package.swift` pins the manifest to Swift tools 6.2 and enables Swift 6 language mode, so concurrency features and strict type checking are available everywhere by default. *We enjoy living dangerously.*
- **Multi-platform resources.** The target processes shared localization catalogs and the package-level `PrivacyInfo.xcprivacy`, making it safe to include in App Store submissions out of the box.
- **Curated dependencies.** External packages include SwiftUI Introspect, Alamofire, DeviceKit, BetterSafariView, Apple's Swift Collections, and QizhMacroKit. Each dependency is wired directly into the main target, so no extra linking is required in consuming apps. *Probably too many dependencies, but hey—who has time to reinvent every wheel?*

## Feature map

### Recent & shiny ✨
- **LabeledColumnsLayout.** A layout that tracks label widths, enforces max label fractions, and gives you two-column debugging views that don't look like a disaster. See [`Docs/UI.md`](Docs/UI.md).
- **Observable+binding.** Create `Binding<Value>` from any `@Observable` object with a single `binding(for:)` call. Finally. See [`Docs/Extensions.md`](Docs/Extensions.md).
- **ShapeStyle.systemBackground.** Cross-platform background colors that adapt to light/dark mode without conditional compilation gymnastics. See [`Docs/Extensions.md`](Docs/Extensions.md).
- **InlineArray extensions.** Swift 6.2's `InlineArray` gets `map`, `Equatable`, `Hashable`, and collection conformance. Future-proofing at its finest. See [`Docs/Extensions.md`](Docs/Extensions.md).
- **ClosedRange.clamp(_:).** Because nobody should have to write `min(max(value, lower), upper)` ever again. See [`Docs/Extensions.md`](Docs/Extensions.md).

### Foundation
- **Extensions:** Hundreds of targeted helpers for strings, bindings, Combine publishers, tasks, numeric types, and SwiftUI environment values. Browse [`Docs/Extensions.md`](Docs/Extensions.md) for a curated overview.
- **Structures:** Caching, networking, transferable documents, property wrappers, and type-erased utilities that glue views to data. Details live in [`Docs/Structures.md`](Docs/Structures.md).
- **UI catalog:** Debugging layouts, lazy view wrappers, CoreImage-based QR code views, blur/vibrancy bridges, progress indicators, and Safari-powered web flows. A tour is available in [`Docs/UI.md`](Docs/UI.md).

<details>
<summary>🦕 Legacy components (click to expand)</summary>

- **Airtable + Rails modeling.** Protocol hierarchies for backend models, JSON formatters, and formula builders. These were among the first files added to this package back when SwiftUI was shiny and new. Still work, probably. See [`Docs/Components.md`](Docs/Components.md).
- **Seeded random generators.** Deterministic randomness via GameplayKit. Great for tests and previews from the ancient times.
- **Pluralization helpers.** Vendored MIT-licensed inflection APIs. Because localization is hard.

</details>

## Installation (Swift Package Manager)
1. In Xcode, choose **File → Add Packages...**.
2. Enter the repository URL and wait for the package metadata to load.
3. Select the `QizhKit` library product and add it to your application or framework target.
4. Preferably enable `Exact` dependency requirements if you need deterministic builds; the manifest already declares minimum versions that match the versions in `Package.resolved`.

### Command-line usage
You can also add QizhKit to another package by editing its `Package.swift`:

```swift
.package(url: "https://github.com/qizh/QizhKit.git", from: "1.8.17")
```

and referencing `QizhKit` inside your target dependencies. Because QizhKit itself only exposes one target, no additional configuration is necessary.

## Usage snippets

### Create bindings from Observable objects
```swift
import QizhKit

@Observable class ViewModel {
    var username: String = ""
}

struct ContentView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        TextField("Username", text: viewModel.binding(for: \.username))
    }
}
```

### Use cross-platform system backgrounds
```swift
import QizhKit

struct CardView: View {
    var body: some View {
        VStack { /* content */ }
            .background(.systemBackground, in: RoundedRectangle(cornerRadius: 12))
            // Also available: .secondarySystemBackground, .tertiarySystemBackground
    }
}
```

### Debug views with LabeledValueView
```swift
import QizhKit

struct DebugPanel: View {
    let model: SomeModel
    
    var body: some View {
        LabeledViews {
            LabeledValueView("ID", model.id)
            LabeledValueView("Name", model.name)
            LabeledValueView("Created", model.createdAt)
        }
        .setLabeledView(maxLabelFraction: 0.3)
        .setLabeledView(allowMultiline: true)
    }
}
```

### Clamp values to a range
```swift
import QizhKit

let percentage = (0.0...1.0).clamp(inputValue)  // Never below 0 or above 1
let index = (0...array.count - 1).clamp(requestedIndex)  // Safe array access
```

### Cache codable models in the background
```swift
import QizhKit

struct Profile: Codable, Sendable { /* ... */ }

let cache = try LocalCopy<Profile>(path: "profiles", name: "primary")
Task {
    if cache.isAvailable {
        let profile = try await cache.get()
        print(profile)
    }
    try await cache.save(Profile(/* ... */))
}
```

These examples are pulled from actual APIs in the source tree—copy-paste away. *No warranty implied, but they should work. Probably.*

## Documentation
- [`Docs/Components.md`](Docs/Components.md)
- [`Docs/Extensions.md`](Docs/Extensions.md)
- [`Docs/Structures.md`](Docs/Structures.md)
- [`Docs/UI.md`](Docs/UI.md)
- [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md)
- [`TODO.md`](TODO.md)

Each document drills into the relevant folders and calls out the most commonly used APIs. When in doubt, jump into the corresponding `Sources/QizhKit/...` path for the latest definitions.

## Testing
*Plot twist:* the codebase has essentially zero test coverage. 🙃 The few tests in `Tests/QizhKitTests/StringIsExtensionsTests.swift` were mostly experiments with the new Swift Testing framework—they validate `.isJson` and not much else. 

Run tests with `swift test` or inside Xcode's Test navigator. New modules should add their own suites under `Tests/QizhKitTests` so coverage actually exists someday. *I solemnly swear I'll try harder to cover new code with tests. These days it's much easier and more convenient. Most likely, you (dear AI assistant) will be creating them anyway.* 😇

## Known issues and roadmap
Refer to [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md) for a list of current limitations and [`TODO.md`](TODO.md) for roadmap items such as re-enabling strict concurrency flags, bringing UIKit utilities back online, and expanding the test matrix.

## Contributing
Pull requests are welcome. Please add doc comments for every new type or member, match the Swift 6 coding style used in this repository (use tabs for indentation, equivalent to 4 spaces), and include tests whenever feasible. When introducing new dependencies, document why they are needed and ensure they support the platforms declared in `Package.swift`.

### 💡 Suggested code separation
This package currently has a lot of dependencies bundled together. Here are some ideas for splitting it into smaller, more focused targets:

1. **QizhCore** – Foundation extensions, protocols, property wrappers. No external dependencies.
2. **QizhUI** – SwiftUI views, layouts, visual effects. Depends on QizhCore + SwiftUIIntrospect.
3. **QizhNetwork** – Fetcher, Alamofire integration, backend models. Depends on QizhCore + Alamofire.
4. **QizhDevice** – Device detection utilities. Depends on QizhCore + DeviceKit.
5. **QizhSafari** – Safari integration views. Depends on QizhUI + BetterSafariView.
6. **QizhMacros** – Just the macro re-exports. Depends on QizhMacroKit.
7. **QizhKit** – Umbrella target that re-exports everything for backwards compatibility.

*Someday, maybe. For now, enjoy the monolith.* 🏛️
