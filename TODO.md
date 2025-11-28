# TODO

*A roadmap of things that should probably happen. Eventually. Maybe.* 🗺️

## Collected `// TODO:` comments from the codebase

These are scattered throughout the source files—gathered here for your convenience (and my shame):

- **AnyTransition+common.swift:12** – Create a transition that clips contents in `ContainerRelativeShape`, scales to 0.98, then slides
- **DispatchQueue+sugar.swift:259** – Finish with Variadic Generics (whenever that becomes practical)
- **StringInterpolation+.swift:54, 59** – Apply formatting in custom string interpolations
- **TimeInterval+convert+format.swift:197** – Implement the time interval formatting extension
- **Flock.swift:31** – Implement the following... *whatever "the following" means; it's in the Off/ graveyard anyway*
- **CollectionAnchor.swift:250** – Implement collection anchor functionality
- **VisualEffects.swift:211** – Implement multiple vibrant layers

---

## Housekeeping

### Clean up the `Off/` graveyard
Audit `Sources/QizhKit/Off`. Decide what's worth resurrecting and what should be properly buried. Each file that makes a comeback needs Swift 6.2 updates and doc comments. *Spoiler: most of it probably stays dead.* 💀

### Migrate deprecated UIKit utilities
Those commented-out files in `Sources/QizhKit/UIKit/` need a decision:
- Move them to `Off/` (most likely)
- Delete them entirely (cleaner)
- Actually fix them (ambitious)

The `InvisibleUIView` and friends are relics from when SwiftUI couldn't handle basic things. SwiftUI has grown up. These haven't.

## Testing (the eternal struggle)

### Actually write tests
`Tests/QizhKitTests/StringIsExtensionsTests.swift` is lonely. It needs friends. Priority candidates:
- `LocalCopy` caching behavior
- `Fetcher` state machine
- `LossyArray` decoding edge cases
- `LabeledColumnsLayout` measurements
- QR code generation

Use the new Swift Testing framework—it's already imported by the existing suite and is *much* nicer to work with.

## Maybe someday

### Split the monolith
This package has too many dependencies for what it is. See the "Suggested code separation" section in README.md for ideas. The goal: let consumers import only what they need without dragging in Alamofire when they just want string extensions.

### Platform support
- visionOS support was removed (or never properly added). Circle back if/when it becomes relevant.
- watchOS is notably absent. On purpose? Oversight? *Who knows.* 🤔

### Documentation
- Add proper DocC documentation generation
- Include runnable code examples
- Generate a documentation website

*This TODO list itself is a form of documentation, I suppose. Meta.* 📝
