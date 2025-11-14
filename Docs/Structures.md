# Structures and data utilities

This package contains a dense `Structures` directory with building blocks that complement SwiftUI views and networking code. Below are the most frequently reused clusters.

## Local storage and caching
`LocalCopy` (see `Structures/Caching/LocalCopy.swift`) is a generic wrapper around the caches directory. It creates folders on demand, reads and writes codable models asynchronously, and exposes helpers such as `date`, `isAvailable`, and `delete()` so you can invalidate cached payloads manually. Because saving runs on a detached task, large blobs do not block the main thread.

## Network fetch pipeline
The `Network` subfolder contains `Fetcher`, a protocol-oriented abstraction that wires Alamofire, Airtable, and SwiftUI previews together. Fetchers hold a `BackendFetchState<Value>` and expose demo states in `#if DEBUG` blocks, making it trivial to preview loading and failure scenarios. Protocol refinements like `SingleItemFetcher`, `CollectionFetcher`, and the publishable variants provide typed state publishers that integrate with ObservableObject bindings.

## Transferable documents
Under `Structures/Transferable`, the `JSONDocument` struct implements the `Transferable` protocol from `CoreTransferable`. It stores `filename` + `Data` pairs, emits `.json` files via `FileRepresentation`, and offers convenience initializers for string literals so that ShareLink interactions can export arbitrary JSON payloads.

## Property wrappers, protocol shims, and other folders
The remaining directories cover specialized areas such as custom property wrappers, `EmptyTestable` collections, measurements, pointer types, type erasure helpers, and reusable enums. Each folder is intentionally small, so browsing for an existing helper before creating a new one typically pays off.
