# Test Coverage Planning

This document tracks unit-test candidates discovered while scanning the QizhKit codebase, grouped by source area. Each entry lists the public APIs worth covering and concrete test ideas to validate their behavior. Checkboxes track implementation status.

## Components/Airtable/AirtableFormulaBuilder.swift
- [x] File: [Components/Airtable/AirtableFormulaBuilder.swift](Components/Airtable/AirtableFormulaBuilder.swift)
  - Public entities to cover
    - [x] `String.StringInterpolation.appendInterpolation(_:)` overloads for formulas and apostrophe escaping
    - [x] `String.withApostrophesEscaped` helper
  - Candidate tests
    - [x] `testProducesAirtableFriendlyStrings` — APIs: `.equals`, `.notEquals`, `.isEmpty`, `.id`. Produce Airtable-friendly strings.
    - [x] `testCombinesFormulasWithAndOrNot` — APIs: `.and`, `.or`, `.not`. Validate `.and`, `.or`, and `.not` nest descriptions correctly for multiple children.
    - [x] `testEscapesApostrophesInInterpolation` — APIs: `appendInterpolation(_:)`, `withApostrophesEscaped`. Verify the custom string interpolation paths escape single quotes consistently for raw values and `RawRepresentable` inputs.

## Components/Random Generators/SeededRandomGenerator.swift
- [ ] File: [Components/Random Generators/SeededRandomGenerator.swift](Components/Random%20Generators/SeededRandomGenerator.swift)
  - Public entities to cover
    - [ ] `SeededRandomGenerator` seeding behavior and `next()` production
  - Candidate tests
    - [ ] `testProducesRepeatableSequence` — Confirm identical seeds emit identical sequences across multiple draws.
    - [ ] `testMixes64BitOutput` — Assert two 32-bit GK samples are combined into varying high/low bits to prevent bias.
    - [ ] `testAdvancesStateBetweenCalls` — Ensure successive `next()` calls mutate generator state (no repeated constant).

## Extensions/String+/String+modify.swift
- [ ] File: [Extensions/String+/String+modify.swift](Extensions/String+/String+modify.swift)
  - Public entities to cover
    - [ ] `StringProtocol` replacement/trim utilities (`replacing`, `withSpacesTrimmed`, `withLinesTrimmed`, `withEmptyLinesTrimmed`, `withLinesNSpacesTrimmed`, `digits`)
    - [ ] Trailing trimming helpers (`trimmingTrailingCharacters`, `withTrailingSpacesTrimmed`, `withTrailingSpacesAndLinesTrimmed`)
    - [ ] Multiplication operator `String * UInt`
    - [ ] `StringOffset` presets and properties
    - [ ] Line offsetting helpers (`offsetting`, `offsettingLines`, `offsettingNewLines`, `tabOffsettingLines`, `tabOffsettingNewLines`)
  - Candidate tests
    - [ ] `testReplacesAndTrimsStrings` — Cover replacements by set/value and trimming behaviors including empty-line removal.
    - [ ] `testTrimsTrailingCharacters` — Verify targeted trailing whitespace/newline removal paths.
    - [ ] `testRepeatsStringWithMultiplicationOperator` — Ensure `"abc" * 3` returns expected concatenation.
    - [ ] `testStringOffsetPresetsEmitExpectedTokens` — Validate `StringOffset` preset suffix/prefix strings and computed properties.
    - [ ] `testOffsetsMultilineBlocks` — Assert offsetting helpers pad each line as documented.

## Structures/Dimensions/GeometryReceivers.swift
- [ ] File: [Structures/Dimensions/GeometryReceivers.swift](Structures/Dimensions/GeometryReceivers.swift)
  - Public entities to cover
    - [ ] View extensions `receiveWidth`, `receiveHeight`, `receiveSafeAreaInsets` for callback and binding variants
  - Candidate tests
    - [ ] `testCapturesWidthAndHeightPreferences` — Inject test views and confirm bindings receive geometry values once layout occurs.
    - [ ] `testInvokesCallbacksOnChange` — Ensure callbacks fire with updated dimensions when layout changes.
    - [ ] `testBindsOptionalAndNonoptionalInsets` — Verify both `EdgeInsets` and `EdgeInsets?` bindings are updated through the preference chain.

## Structures/Dimensions/RelativeDimension.swift
- [ ] File: [Structures/Dimensions/RelativeDimension.swift](Structures/Dimensions/RelativeDimension.swift)
  - Public entities to cover
    - [ ] `RelativeDimension` literal conformance and stored cases (`maximum`, `exactly`, `minimum`)
    - [ ] Computed values (`value`, `maxValue`, `extraPadding`)
    - [ ] Comparison helpers (`is(_:)`, `isMaximum`, `isExact`, `isMinimum`)
  - Candidate tests
    - [ ] `testInitializesFromLiterals` — Confirm float/integer literal initializers map to `.exactly` with converted `CGFloat`.
    - [ ] `testExposesValueAndMaxValue` — Validate optional outputs for `exactly` vs `maximum` cases.
    - [ ] `testMinimumCaseReportsPadding` — Ensure `.minimum` carries the provided padding.
    - [ ] `testComparisonHelpersMatchCases` — Test `is` and convenience flags across all permutations.

## Structures/Type Erase/AnyComparable.swift
- [ ] File: [Structures/Type Erase/AnyComparable.swift](Structures/Type%20Erase/AnyComparable.swift)
  - Public entities to cover
    - [ ] `AnyComparable` boxing behavior
    - [ ] `Comparable`/`Equatable` conformance
    - [ ] `Comparable.asAnyComparable()` helper
  - Candidate tests
    - [ ] `testComparesBoxedValues` — Assert `<` and `==` use underlying `Comparable` semantics for same-typed boxes.
    - [ ] `testHandlesCrossTypeComparisonsSafely` — Ensure comparisons with different underlying types return `false` without crashes.
    - [ ] `testWrapsComparableValues` — Verify `.asAnyComparable()` wraps and preserves ordering in sorted collections.

## Structures/Type Erase/AnyHashableAndSendable.swift
- [ ] File: [Structures/Type Erase/AnyHashableAndSendable.swift](Structures/Type%20Erase/AnyHashableAndSendable.swift)
  - Public entities to cover
    - [ ] Property wrappers `AnyHashableAndSendable`, `AnySendableEncodable`, `AnyHashableSendableEncodable` and their nested box types
    - [ ] Protocols (`HashableAndSendableAdoptable`, `SendableEncodableAdoptable`, `HashableSendableEncodableAdoptable`)
    - [ ] Encoding helpers on `[AnyHashable: Any]` (`asEncodedJsonString`, `asEncodedJson5string`)
  - Candidate tests
    - [ ] `testBoxesPreserveHashAndEquality` — Verify wrappers round-trip `Hashable`/`Sendable` values and compare correctly across identical and differing types.
    - [ ] `testEncodesWrappedValues` — Ensure encodable wrappers forward encoding to the underlying value and produce expected JSON/JSON5 strings.
    - [ ] `testSupportsPropertyWrapperInitStyles` — Cover both `init(wrappedValue:)` and direct initializers for each wrapper.
    - [ ] `testHandlesNonEncodableDictionaryEntries` — Assert encoding helpers return the fallback message when dictionary cannot be cast to `Encodable`.

## Ugly/WindowUtils.swift
- [ ] File: [Ugly/WindowUtils.swift](Ugly/WindowUtils.swift)
  - Public entities to cover
    - [ ] `WindowUtils` window accessors (`setOriginalWindow`, `windowScene`, `keyWindow`, `rootViewController`, `originalWindow`, `currentWindow`, `topViewController`)
    - [ ] Global helpers `endEditing(force:)` and `SafeFrame.currentInsets`
  - Candidate tests
    - [ ] `testTracksManuallyAssignedWindow` — Confirm `setOriginalWindow` overrides lookup and restores when cleared.
    - [ ] `testResolvesTopViewController` — Simulate navigation/tab/presentation stacks to ensure the traversal selects the visible controller.
    - [ ] `testEndsEditingThroughCurrentWindow` — Verify `endEditing(force:)` relays to the active window and respects the `force` flag.
    - [ ] `testReportsSafeAreaInsets` — Validate `SafeFrame.currentInsets` mirrors the active window's safe area.

## Third Party/Pluralize/Pluralize.swift
- [ ] File: [Third Party/Pluralize/Pluralize.swift](Third%20Party/Pluralize/Pluralize.swift)
  - Public entities to cover
    - [ ] `Pluralize` class API (`apply`, `applySingular`, `rule`, `singularRule`, `uncountable`, `unchanging`, instance rule collections`)
  - Candidate tests
    - [ ] `testPluralizesAndSingularizesCommonWords` — Check irregular and regular transformations for representative samples.
    - [ ] `testHonorsUncountableAndUnchangingLists` — Confirm words in those collections return unchanged results.
    - [ ] `testAddsRuntimeRules` — Ensure dynamically added plural/singular rules apply ahead of defaults.

---

**Summary:** 9 scopes with 32 proposed test cases covering deterministic behavior, string processing, geometry preference wiring, type erasure semantics, UIKit helpers, and pluralization utilities across QizhKit.
