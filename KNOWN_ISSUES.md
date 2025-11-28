# Known issues

*A curated list of "features" that are actually limitations. You're welcome.* 😏

## `Off/` is the code graveyard
`Package.swift` explicitly excludes the `Sources/QizhKit/Off` directory. This folder is where code goes to retire—it's an archive of outdated implementations that are no longer maintained and probably won't even build anymore. Think of it as a museum of "seemed like a good idea at the time."

**What's in there?** Things like `Flock`, `LineStack`, localized string utilities, and other helpers from the early SwiftUI days. If you're feeling archaeologically curious, you can remove the `exclude` entry from `Package.swift` and see what happens. *No guarantees. Good luck.* 🦴

## UIKit utilities are mostly abandoned
Files under `Sources/QizhKit/UIKit/` (like `InvisibleUIView.swift`) are either commented out or deprecated. These were written back when SwiftUI was a baby and couldn't do basic things—so I had to bridge to UIKit. Now SwiftUI has grown up, and these files have been collecting dust ever since.

**Current status:** Not maintained, not in use, and really should be moved to `Off/` folder. *I just... forgot about them. Or ran out of time. Both, probably.* 🤷

## Testing is aspirational
`Tests/QizhKitTests` contains exactly one test file (`StringIsExtensionsTests.swift`) that exercises the `.isJson` helper. That's it. The rest of the codebase is living dangerously without a safety net.

**Reality check:** Those tests were mostly experiments with the new Swift Testing framework, not a comprehensive test suite. Regressions can and will sneak in unnoticed.

## Commented-out Swift settings
The `swiftSettings` section in `Package.swift` has some settings that look suspiciously disabled:

```swift
// .defaultIsolation(MainActor.self)
// .enableExperimentalFeature("StrictConcurrency=complete", .when(configuration: .debug))
// .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"], .when(configuration: .debug))
// .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
```

**Why?** As of Swift 6.2 (the latest stable version as of late 2025), most of these flags are either:
- Built into the language mode by default (Swift 6 enables strict concurrency)
- No longer experimental features
- Potentially problematic with certain dependency combinations

The `defaultIsolation(MainActor.self)` might still be useful for UI-heavy code, but it's intentionally left commented out to avoid forcing a specific isolation model on consumers of this package. *Feel free to uncomment if you enjoy compiler errors.*
