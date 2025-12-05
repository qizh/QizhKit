# Test Coverage Planning

This document tracks unit-test candidates discovered while scanning the QizhKit codebase, grouped by source area. Each entry lists the public APIs worth covering and concrete test ideas to validate their behavior.

## ⊞ [Components/Airtable/AirtableFormulaBuilder.swift](Components/Airtable/AirtableFormulaBuilder.swift)

<table>
  <tr>
    <th>Public entities to cover</th>
    <th>Candidate tests</th>
  </tr>
  <tr>
    <td>
      
- `String.StringInterpolation.appendInterpolation(_:)` overloads for formulas and apostrophe escaping
- `String.withApostrophesEscaped` helper
    </td>
    <td>
      <table>
        <tr>
          <th alignment="leading">Name</th>
          <th>Description</th>
        </tr>
        <tr>                             <!-- ╭────┘ 1 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testProducesAirtableFriendlyStrings`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Produce Airtable-friendly strings
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 2 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testCombinesFormulasWithAndOrNot`
          </td>
          <td>                           <!-- ├❴ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣 ❵────┤ -->
Validate `.and`, `.or`, and `.not` nest descriptions correctly for multiple children
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 3 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testEscapesApostrophesInInterpolation`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Verify the custom string interpolation paths escape single quotes consistently for raw values and `RawRepresentable` inputs
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
      </table>
    </td>
  </tr>
</table>

## ⊞ [Components/Random Generators/SeededRandomGenerator.swift](Components/Random%20Generators/SeededRandomGenerator.swift)

<table>
  <tr>
    <th>Public entities to cover</th>
    <th>Candidate tests</th>
  </tr>
  <tr>
    <td>

- `SeededRandomGenerator` seeding behavior and `next()` production
    </td>
    <td>
      <table>
        <tr>
          <th alignment="leading">Name</th>
          <th>Description</th>
        </tr>
        <tr>                             <!-- ╭────┘ 1 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testProducesRepeatableSequence`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Confirm identical seeds emit identical sequences across multiple draws
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 2 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testMixes64BitOutput`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Assert two 32-bit GK samples are combined into varying high/low bits to prevent bias
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 3 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testAdvancesStateBetweenCalls`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Ensure successive `next()` calls mutate generator state (no repeated constant)
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
      </table>
    </td>
  </tr>
</table>

## ⊞ [Extensions/String+/String+modify.swift](Extensions/String+/String+modify.swift)

<table>
  <tr>
    <th>Public entities to cover</th>
    <th>Candidate tests</th>
  </tr>
  <tr>
    <td>

- `StringProtocol` replacement/trim utilities (`replacing`, `withSpacesTrimmed`, `withLinesTrimmed`, `withEmptyLinesTrimmed`, `withLinesNSpacesTrimmed`, `digits`)
- Trailing trimming helpers (`trimmingTrailingCharacters`, `withTrailingSpacesTrimmed`, `withTrailingSpacesAndLinesTrimmed`)
- Multiplication operator `String * UInt`
- `StringOffset` presets and properties
- Line offsetting helpers (`offsetting`, `offsettingLines`, `offsettingNewLines`, `tabOffsettingLines`, `tabOffsettingNewLines`)
    </td>
    <td>
      <table>
        <tr>
          <th alignment="leading">Name</th>
          <th>Description</th>
        </tr>
        <tr>                             <!-- ╭────┘ 1 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testReplacesAndTrimsStrings`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Cover replacements by set/value and trimming behaviors including empty-line removal
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 2 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testTrimsTrailingCharacters`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Verify targeted trailing whitespace/newline removal paths
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 3 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testRepeatsStringWithMultiplicationOperator`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Ensure `"abc" * 3` returns expected concatenation
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 4 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testStringOffsetPresetsEmitExpectedTokens`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Validate `StringOffset` preset suffix/prefix strings and computed properties
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 5 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testOffsetsMultilineBlocks`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Assert offsetting helpers pad each line as documented
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
      </table>
    </td>
  </tr>
</table>

## ⊞ [Structures/Dimensions/GeometryReceivers.swift](Structures/Dimensions/GeometryReceivers.swift)

<table>
  <tr>
    <th>Public entities to cover</th>
    <th>Candidate tests</th>
  </tr>
  <tr>
    <td>

- View extensions `receiveWidth`, `receiveHeight`, `receiveSafeAreaInsets` for callback and binding variants
    </td>
    <td>
      <table>
        <tr>
          <th alignment="leading">Name</th>
          <th>Description</th>
        </tr>
        <tr>                             <!-- ╭────┘ 1 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testCapturesWidthAndHeightPreferences`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Inject test views and confirm bindings receive geometry values once layout occurs
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 2 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testInvokesCallbacksOnChange`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Ensure callbacks fire with updated dimensions when layout changes
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 3 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testBindsOptionalAndNonoptionalInsets`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Verify both `EdgeInsets` and `EdgeInsets?` bindings are updated through the preference chain
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
      </table>
    </td>
  </tr>
</table>

## ⊞ [Structures/Dimensions/RelativeDimension.swift](Structures/Dimensions/RelativeDimension.swift)

<table>
  <tr>
    <th>Public entities to cover</th>
    <th>Candidate tests</th>
  </tr>
  <tr>
    <td>

- `RelativeDimension` literal conformance and stored cases (`maximum`, `exactly`, `minimum`)
- Computed values (`value`, `maxValue`, `extraPadding`)
- Comparison helpers (`is(_:)`, `isMaximum`, `isExact`, `isMinimum`)
    </td>
    <td>
      <table>
        <tr>
          <th alignment="leading">Name</th>
          <th>Description</th>
        </tr>
        <tr>                             <!-- ╭────┘ 1 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testInitializesFromLiterals`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Confirm float/integer literal initializers map to `.exactly` with converted `CGFloat`
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 2 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testExposesValueAndMaxValue`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Validate optional outputs for `exactly` vs `maximum` cases
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 3 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testMinimumCaseReportsPadding`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Ensure `.minimum` carries the provided padding
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 4 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testComparisonHelpersMatchCases`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Test `is` and convenience flags across all permutations
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
      </table>
    </td>
  </tr>
</table>

## ⊞ [Structures/Type Erase/AnyComparable.swift](Structures/Type%20Erase/AnyComparable.swift)

<table>
  <tr>
    <th>Public entities to cover</th>
    <th>Candidate tests</th>
  </tr>
  <tr>
    <td>

- `AnyComparable` boxing behavior
- `Comparable`/`Equatable` conformance
- `Comparable.asAnyComparable()` helper
    </td>
    <td>
      <table>
        <tr>
          <th alignment="leading">Name</th>
          <th>Description</th>
        </tr>
        <tr>                             <!-- ╭────┘ 1 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testComparesBoxedValues`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Assert `<` and `==` use underlying `Comparable` semantics for same-typed boxes
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 2 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testHandlesCrossTypeComparisonsSafely`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Ensure comparisons with different underlying types return `false` without crashes
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 3 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testWrapsComparableValues`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Verify `.asAnyComparable()` wraps and preserves ordering in sorted collections
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
      </table>
    </td>
  </tr>
</table>

## ⊞ [Structures/Type Erase/AnyHashableAndSendable.swift](Structures/Type%20Erase/AnyHashableAndSendable.swift)

<table>
  <tr>
    <th>Public entities to cover</th>
    <th>Candidate tests</th>
  </tr>
  <tr>
    <td>

- Property wrappers `AnyHashableAndSendable`, `AnySendableEncodable`, `AnyHashableSendableEncodable` and their nested box types
- Protocols (`HashableAndSendableAdoptable`, `SendableEncodableAdoptable`, `HashableSendableEncodableAdoptable`)
- Encoding helpers on `[AnyHashable: Any]` (`asEncodedJsonString`, `asEncodedJson5string`)
    </td>
    <td>
      <table>
        <tr>
          <th alignment="leading">Name</th>
          <th>Description</th>
        </tr>
        <tr>                             <!-- ╭────┘ 1 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testBoxesPreserveHashAndEquality`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Verify wrappers round-trip `Hashable`/`Sendable` values and compare correctly across identical and differing types
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 2 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testEncodesWrappedValues`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Ensure encodable wrappers forward encoding to the underlying value and produce expected JSON/JSON5 strings
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 3 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testSupportsPropertyWrapperInitStyles`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Cover both `init(wrappedValue:)` and direct initializers for each wrapper
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 4 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testHandlesNonEncodableDictionaryEntries`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Assert encoding helpers return the fallback message when dictionary cannot be cast to `Encodable`
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
      </table>
    </td>
  </tr>
</table>

## ⊞ [Ugly/WindowUtils.swift](Ugly/WindowUtils.swift)

<table>
  <tr>
    <th>Public entities to cover</th>
    <th>Candidate tests</th>
  </tr>
  <tr>
    <td>

- `WindowUtils` window accessors (`setOriginalWindow`, `windowScene`, `keyWindow`, `rootViewController`, `originalWindow`, `currentWindow`, `topViewController`)
- Global helpers `endEditing(force:)` and `SafeFrame.currentInsets`
    </td>
    <td>
      <table>
        <tr>
          <th alignment="leading">Name</th>
          <th>Description</th>
        </tr>
        <tr>                             <!-- ╭────┘ 1 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testTracksManuallyAssignedWindow`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Confirm `setOriginalWindow` overrides lookup and restores when cleared
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 2 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testResolvesTopViewController`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Simulate navigation/tab/presentation stacks to ensure the traversal selects the visible controller
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 3 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testEndsEditingThroughCurrentWindow`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Verify `endEditing(force:)` relays to the active window and respects the `force` flag
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 4 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testReportsSafeAreaInsets`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Validate `SafeFrame.currentInsets` mirrors the active window's safe area
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
      </table>
    </td>
  </tr>
</table>

## ⊞ [Third Party/Pluralize/Pluralize.swift](Third%20Party/Pluralize/Pluralize.swift)

<table>
  <tr>
    <th>Public entities to cover</th>
    <th>Candidate tests</th>
  </tr>
  <tr>
    <td>

- `Pluralize` class API (`apply`, `applySingular`, `rule`, `singularRule`, `uncountable`, `unchanging`, instance rule collections)
    </td>
    <td>
      <table>
        <tr>
          <th alignment="leading">Name</th>
          <th>Description</th>
        </tr>
        <tr>                             <!-- ╭────┘ 1 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testPluralizesAndSingularizesCommonWords`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Check irregular and regular transformations for representative samples
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 2 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testHonorsUncountableAndUnchangingLists`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Confirm words in those collections return unchanged results
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 3 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`testAddsRuntimeRules`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Ensure dynamically added plural/singular rules apply ahead of defaults
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
      </table>
    </td>
  </tr>
</table>

---

**Summary:** 9 scopes with 32 proposed test cases covering deterministic behavior, string processing, geometry preference wiring, type erasure semantics, UIKit helpers, and pluralization utilities across QizhKit.
