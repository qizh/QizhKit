# Components

QizhKit groups higher-level features into the **Components** directory so that concrete business logic can be reused outside of a specific app target. Each component is documented below for quick discovery.

*Confession time: most of this folder contains code from the early days of the package. It still works, but it's not exactly cutting-edge.* 🦕

## Localization bundles
The `Localizations` folder contains `.xcstrings` catalogs for app strings and unit names (including the recently added `Units.xcstrings` with audio channel and counting unit localizations). Because the package declares `defaultLocalization = "en"` and processes this directory as a resource, you can bundle translations for any client of the library without a separate resource target.

## Third-party inclusions
The `Third Party/Pluralize` module vendors the MIT-licensed `Pluralize.swift` helper, exposing inflection APIs such as `pluralize(count:with:)` for human-readable strings. Keeping the code locally avoids additional package dependencies while retaining attribution inside the source file header.

## Randomized utilities
The `Random Generators` folder introduces `SeededRandomGenerator`, a deterministic `RandomNumberGenerator` wrapper powered by GameplayKit's `GKMersenneTwisterRandomSource`. It builds 64-bit values from paired 32-bit samples, letting you drive repeatable tests, previews, or demo data with a known seed.

<details>
<summary>🦕 Airtable + Rails modeling (legacy, but functional)</summary>

*These were among the first files added to this package. They predate most of the SwiftUI era and show their age.*

The files inside `Sources/QizhKit/Components/Airtable` implement a layered protocol hierarchy that makes Airtable-backed models usable inside SwiftUI previews, live apps, or scripts.

- `AirtableModel.swift` defines several protocols. `InitializableWithJsonString` adds string literal decoding so that small demo records can be declared inline, and `BackendModel` chains together `Decodable`, `Identifiable`, hashing, and pretty-printing so that shared models have uniform capabilities. `KeyedBackendModel` and `KeyedEmptyableBackendModel` expand on that base by exposing `CodingKeys` and a custom `value(for:)` helper that can decode an individual property from the encoded payload when necessary. `RailsModel` then adds default fetcher callbacks and default server responses for REST endpoints, completed by the strongly typed `RailsResponse`, `RailsLossyResponses`, and `RailsStrictResponses` structures for handling success and partially corrupted payloads.
- `Airtable+coding.swift` supplies tuned JSON formatters and decoders for Airtable, GraphQL, and Rails APIs. The factory properties configure ISO-8601 date parsing, JSON5 support, and pretty printed encoding, keeping backend interactions consistent regardless of the client.
- `AirtableFormulaBuilder.swift` exposes the `AirtableFormulaBuilder` enum, a composable DSL for producing Airtable formula strings. It supports search, equality/inequality checks, ID matching, negation, and arbitrary `AND`/`OR` chains with custom string interpolation helpers so requests remain readable.

Together these types enable a full cycle: define a backend model, serialize or deserialize it with the supplied formatters, and generate Airtable queries without recreating string-based logic in every product.

*If you're actually using Airtable in 2025, godspeed.* 🙏

</details>
