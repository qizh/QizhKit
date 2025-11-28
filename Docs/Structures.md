# Structures and data utilities

This package contains a dense `Structures` directory with building blocks that complement SwiftUI views and networking code. Below are the most frequently reused clusters.

*Recent additions first, archaeological finds at the bottom.* 🏺

## Recent additions ✨

### Transferable documents
Under `Structures/Transferable`, the `JSONDocument` struct implements the `Transferable` protocol from `CoreTransferable`. It stores `filename` + `Data` pairs, emits `.json` files via `FileRepresentation`, and offers convenience initializers for string literals so that ShareLink interactions can export arbitrary JSON payloads. *Finally, sharing JSON is easy.*

### Custom measurements
- `UnitAudioChannel.swift` defines custom `Dimension` subclasses for audio channels (mono, stereo, quad, surround) and general counting (piece, dozen, pair, thousand). Complete with localized unit names via `UnitAudioChannelLocalization`.
- `Measurement<UnitFrequency>` now conforms to `Strideable` for convenient iteration.

### LossyArray improvements
`LossyArray` now has a `count` property and refined `EmptyProvidable` conformance. It gracefully decodes arrays while logging and skipping invalid elements—perfect for APIs that occasionally return garbage.

### Protocol refinements
- `EmptyTestable` gets `OrderedDictionary` conformance and refined constraints.
- `Observable+stream.swift` moved to Extensions for better organization.
- `CaseNameProvider` and `CasesBridgeProvider` protocols match the new macro system.

### FetchError expansion
`FetchError` now has `CustomStringConvertible` conformance and a `multipleErrors(_:)` case for when everything goes wrong at once.

## Local storage and caching
`LocalCopy` (see `Structures/Caching/LocalCopy.swift`) is a generic wrapper around the caches directory. It creates folders on demand, reads and writes codable models asynchronously, and exposes helpers such as `date`, `isAvailable`, and `delete()` so you can invalidate cached payloads manually. Because saving runs on a detached task, large blobs do not block the main thread.

## Network fetch pipeline
The `Network` subfolder contains `Fetcher`, a protocol-oriented abstraction that wires Alamofire, Airtable, and SwiftUI previews together. Fetchers hold a `BackendFetchState<Value>` and expose demo states in `#if DEBUG` blocks, making it trivial to preview loading and failure scenarios. Protocol refinements like `SingleItemFetcher`, `CollectionFetcher`, and the publishable variants provide typed state publishers that integrate with ObservableObject bindings.

## Codable utilities
- `JSON5Encoder` for modern JSON encoding
- `LossyArray` for fault-tolerant array decoding
- `RawJson` property wrapper with `asJsonString(encoder:)` method
- `CodableAnyDictionary` and `CodableAnyArray` for dynamic JSON structures
- `DontEncodeEmpty` for omitting empty values during encoding
- `CodingError+HumanReadable` for readable error messages

## Property wrappers
- `Clamped` for keeping values within bounds
- `Lazy` for deferred initialization
- Various other wrappers scattered throughout

<details>
<summary>🦕 Legacy structures (still functional, just older)</summary>

- Pointer types and type erasure helpers
- Collection protocols and anchors
- Enums and utility types
- The whole Airtable model stack

*These work fine, they're just not the shiny new toys.*

</details>
