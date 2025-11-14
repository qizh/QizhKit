# Known issues

## `Off/` sources are excluded from the target
`Package.swift` explicitly excludes the `Sources/QizhKit/Off` directory, so helpers such as `Flock`, `LineStack`, or the localized string utilities cannot be imported even though they live in the repository. If you need them, remove the entry inside the `exclude` array and verify that the files still build under Swift 6.1.

## UIKit-only utilities are partially disabled
`Sources/QizhKit/UIKit/InvisibleUIView.swift` is currently commented out, so the type is unavailable despite existing in the tree. Projects that reference `InvisibleUIView` will fail to compile until the implementation is restored or the references are removed.

## Limited automated tests
`Tests/QizhKitTests` only contains `StringIsExtensionsTests`, which exercises the `.isJson` helper. No other components, views, or structures are covered, so regressions can sneak in unnoticed. Additional suites are required to cover networking helpers, SwiftUI layouts, and the Airtable model stack.

## Strict concurrency/optimization flags disabled
The `swiftSettings` section in `Package.swift` has commented-out calls to `.defaultIsolation`, `.enableExperimentalFeature`, and `.unsafeFlags` for strict concurrency and cross-module optimization. Without them, async code compiles with relaxed rules and fewer compiler diagnostics, making it harder to detect thread-safety regressions early.
