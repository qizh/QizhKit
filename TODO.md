# TODO

## Restore `Off/` components when ready
Audit the files currently stored under `Sources/QizhKit/Off`, move the ones that still make sense into active folders, and remove the exclusion entry from `Package.swift`. Each resurrected file will need Swift 6.1 annotations and doc comments.

## Re-enable strict concurrency experiments
Decide whether `.defaultIsolation(MainActor.self)` and `.enableExperimentalFeature("StrictConcurrency=complete")` should ship as active `swiftSettings`. If so, uncomment the existing lines, gate them by configuration, and fix any data races exposed by the compiler.

## Expand UI availability on UIKit
`Sources/QizhKit/UIKit/InvisibleUIView.swift` is fully commented out. Bring it back (or delete it) so UIKit clients do not reference a phantom type. A modernized replacement should guard any APIs that are unavailable in extensions.

## Add integration tests beyond strings
`Tests/QizhKitTests/StringIsExtensionsTests.swift` is a starting point, but the majority of helpers remain untested. Start by covering `LocalCopy` caching, QR code rendering, and the `Fetcher` state machine using the new `Testing` library that is already imported by the existing suite.
