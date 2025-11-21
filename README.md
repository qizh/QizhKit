# QizhKit

A Swift 6 toolkit that bundles SwiftUI building blocks, backend-facing models, localization catalogs, and a deep set of extensions for day-to-day app development. The package targets iOS 17, macOS 14, macCatalyst 17, and visionOS 1 while shipping as a single library product named `QizhKit`.

## Overview
- **Latest Swift toolchain.** `Package.swift` pins the manifest to Swift tools 6.1 and enables Swift 6 language mode, so concurrency features and strict type checking are available everywhere by default.
- **Multi-platform resources.** The target processes shared localization catalogs and the package-level `PrivacyInfo.xcprivacy`, making it safe to include in App Store submissions out of the box.
- **Curated dependencies.** External packages include SwiftUI Introspect, Alamofire, DeviceKit, BetterSafariView, Apple's Swift Collections, and QizhMacroKit. Each dependency is wired directly into the main target, so no extra linking is required in consuming apps.

## Feature map
- **Components:** Airtable + Rails model protocols, JSON encoders/decoders, formula builders, seeded random generators, localization catalogs, and vendored pluralization helpers. See [`Docs/Components.md`](Docs/Components.md).
- **Extensions:** Hundreds of targeted helpers for strings, bindings, Combine publishers, tasks, numeric types, and SwiftUI environment values. Browse [`Docs/Extensions.md`](Docs/Extensions.md) for a curated overview.
- **Structures:** Caching, networking, transferable documents, property wrappers, and type-erased utilities that glue views to data. Details live in [`Docs/Structures.md`](Docs/Structures.md).
- **UI catalog:** Debugging layouts, lazy view wrappers, CoreImage-based QR code views, blur/vibrancy bridges, progress indicators, and Safari-powered web flows. A tour is available in [`Docs/UI.md`](Docs/UI.md).

## Installation (Swift Package Manager)
1. In Xcode, choose **File → Add Packages...**.
2. Enter the repository URL and wait for the package metadata to load.
3. Select the `QizhKit` library product and add it to your application or framework target.
4. Optionally enable `Exact` dependency requirements if you need deterministic builds; the manifest already declares minimum versions that match the versions in `Package.resolved`.

### Command-line usage
You can also add QizhKit to another package by editing its `Package.swift`:

```swift
.package(url: "https://github.com/<owner>/QizhKit.git", branch: "main")
```

and referencing `QizhKit` inside your target dependencies. Because QizhKit itself only exposes one target, no additional configuration is necessary.

## Usage snippets
### Validate strings without regex copies
```swift
import QizhKit

let email = "hello@example.com"
if email.isValidEmail {
        // Display signup button
}

if "{id: 2}".isJson {
        // Parse JSON5 payloads without rewriting trimming logic
}
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

### Present a Safari fallback button
```swift
import QizhKit

SafariButton(title: Text("View docs"), opening: url, tintColor: .accentColor) {
        print("Universal link failed → showing SFSafariViewController")
}
```

These examples mirror the actual APIs provided in the source tree so you can copy them directly into your project.

## Documentation
- [`Docs/Components.md`](Docs/Components.md)
- [`Docs/Extensions.md`](Docs/Extensions.md)
- [`Docs/Structures.md`](Docs/Structures.md)
- [`Docs/UI.md`](Docs/UI.md)
- [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md)
- [`TODO.md`](TODO.md)

Each document drills into the relevant folders and calls out the most commonly used APIs. When in doubt, jump into the corresponding `Sources/QizhKit/...` path for the latest definitions.

## Testing
The repository currently includes `Tests/QizhKitTests/StringIsExtensionsTests.swift`, which uses the Swift `Testing` package to validate the `.isJson` helper. Run tests with `swift test` or inside Xcode's Test navigator. New modules should add their own suites under `Tests/QizhKitTests` so coverage keeps up with future releases.

## Known issues and roadmap
Refer to [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md) for a list of current limitations and [`TODO.md`](TODO.md) for roadmap items such as re-enabling strict concurrency flags, bringing UIKit utilities back online, and expanding the test matrix.

## Contributing
Pull requests are welcome. Please add doc comments for every new type or member, match the Swift 6 coding style used in this repository (spaces equal tabs of four characters), and include tests whenever feasible. When introducing new dependencies, document why they are needed and ensure they support the platforms declared in `Package.swift`.
