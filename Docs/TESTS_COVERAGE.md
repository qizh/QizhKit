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
`.equals`, `.notEquals`, `.isEmpty`, and `.id`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Produce Airtable-friendly strings
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 2 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`combines_formulas_with_and_or_not`
          </td>
          <td>                           <!-- ├❴ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣 ❵────┤ -->
Validate `.and`, `.or`, and `.not` nest descriptions correctly for multiple children
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
        <tr>                             <!-- ╭────┘ 3 └───────╮ -->
          <td>                           <!-- ├ 𝙉𝙖𝙢𝙚           │ -->
`escapes_apostrophes_in_interpolation`
          </td>
          <td>                           <!-- ├ 𝘿𝙚𝙨𝙘𝙧𝙞𝙥𝙩𝙞𝙤𝙣       │ -->
Verify the custom string interpolation paths escape single quotes consistently for raw values and `RawRepresentable` inputs
          </td>
        </tr>                            <!-- ╰────────────────╯ -->
      </table>
    </td>
  </tr>
</table>

<details>
  <summary>TODO</summary>
  
- [ ] Divide the following table into sections with tables, like the one above was made out of the first row previously present in the following table.

| Public entities to cover | Candidate tests (name — description) |
|:-------------------------|:-------------------------------------|
| Components/Random Generators/SeededRandomGenerator.swift | `SeededRandomGenerator` seeding behavior and `next()` production | `produces_repeatable_sequence` — confirm identical seeds emit identical sequences across multiple draws;<br>`mixes_64bit_output` — assert two 32-bit GK samples are combined into varying high/low bits to prevent bias;<br>`advances_state_between_calls` — ensure successive `next()` calls mutate generator state (no repeated constant). |
| Extensions/String+/String+modify.swift | `StringProtocol` replacement/trim utilities (`replacing`, `withSpacesTrimmed`, `withLinesTrimmed`, `withEmptyLinesTrimmed`, `withLinesNSpacesTrimmed`, `digits`);<br>Trailing trimming helpers (`trimmingTrailingCharacters`, `withTrailingSpacesTrimmed`, `withTrailingSpacesAndLinesTrimmed`);<br>Multiplication operator `String * UInt`;<br>`StringOffset` presets and properties;<br>Line offsetting helpers (`offsetting`, `offsettingLines`, `offsettingNewLines`, `tabOffsettingLines`, `tabOffsettingNewLines`) | `replaces_and_trims_strings` — cover replacements by set/value and trimming behaviors including empty-line removal;<br>`trims_trailing_characters` — verify targeted trailing whitespace/newline removal paths;<br>`repeats_string_with_multiplication_operator` — ensure `"abc" * 3` returns expected concatenation;<br>`string_offset_presets_emit_expected_tokens` — validate `StringOffset` preset suffix/prefix strings and computed properties;<br>`offsets_multiline_blocks` — assert offsetting helpers pad each line as documented. |
| Structures/Dimensions/GeometryReceivers.swift | View extensions `receiveWidth`, `receiveHeight`, `receiveSafeAreaInsets` for callback and binding variants | `captures_width_and_height_preferences` — inject test views and confirm bindings receive geometry values once layout occurs;<br>`invokes_callbacks_on_change` — ensure callbacks fire with updated dimensions when layout changes;<br>`binds_optional_and_nonoptional_insets` — verify both `EdgeInsets` and `EdgeInsets?` bindings are updated through the preference chain. |
| Structures/Dimensions/RelativeDimension.swift | `RelativeDimension` literal conformance and stored cases (`maximum`, `exactly`, `minimum`);<br>Computed values (`value`, `maxValue`, `extraPadding`);<br>Comparison helpers (`is(_:)`, `isMaximum`, `isExact`, `isMinimum`) | `initializes_from_literals` — confirm float/integer literal initializers map to `.exactly` with converted `CGFloat`;<br>`exposes_value_and_maxValue` — validate optional outputs for `exactly` vs `maximum` cases;<br>`minimum_case_reports_padding` — ensure `.minimum` carries the provided padding;<br>`comparison_helpers_match_cases` — test `is` and convenience flags across all permutations. |
| Structures/Type Erase/AnyComparable.swift | `AnyComparable` boxing behavior; `Comparable`/`Equatable` conformance; `Comparable.asAnyComparable()` helper | `compares_boxed_values` — assert `<` and `==` use underlying `Comparable` semantics for same-typed boxes;<br>`handles_cross_type_comparisons_safely` — ensure comparisons with different underlying types return `false` without crashes;<br>`wraps_comparable_values` — verify `.asAnyComparable()` wraps and preserves ordering in sorted collections. |
| Structures/Type Erase/AnyHashableAndSendable.swift | Property wrappers `AnyHashableAndSendable`, `AnySendableEncodable`, `AnyHashableSendableEncodable` and their nested box types;<br>Protocols (`HashableAndSendableAdoptable`, `SendableEncodableAdoptable`, `HashableSendableEncodableAdoptable`);<br>Encoding helpers on `[AnyHashable: Any]` (`asEncodedJsonString`, `asEncodedJson5string`) | `boxes_preserve_hash_and_equality` — verify wrappers round-trip `Hashable`/`Sendable` values and compare correctly across identical and differing types;<br>`encodes_wrapped_values` — ensure encodable wrappers forward encoding to the underlying value and produce expected JSON/JSON5 strings;<br>`supports_property_wrapper_init_styles` — cover both `init(wrappedValue:)` and direct initializers for each wrapper;<br>`handles_non_encodable_dictionary_entries` — assert encoding helpers return the fallback message when dictionary cannot be cast to `Encodable`. |
| Ugly/WindowUtils.swift | `WindowUtils` window accessors (`setOriginalWindow`, `windowScene`, `keyWindow`, `rootViewController`, `originalWindow`, `currentWindow`, `topViewController`);<br>Global helpers `endEditing(force:)` and `SafeFrame.currentInsets` | `tracks_manually_assigned_window` — confirm `setOriginalWindow` overrides lookup and restores when cleared;<br>`resolves_top_view_controller` — simulate navigation/tab/presentation stacks to ensure the traversal selects the visible controller;<br>`ends_editing_through_current_window` — verify `endEditing(force:)` relays to the active window and respects the `force` flag;<br>`reports_safe_area_insets` — validate `SafeFrame.currentInsets` mirrors the active window’s safe area. |
| Third Party/Pluralize/Pluralize.swift | `Pluralize` class API (`apply`, `applySingular`, `rule`, `singularRule`, `uncountable`, `unchanging`, instance rule collections) | `pluralizes_and_singularizes_common_words` — check irregular and regular transformations for representative samples;<br>`honors_uncountable_and_unchanging_lists` — confirm words in those collections return unchanged results;<br>`adds_runtime_rules` — ensure dynamically added plural/singular rules apply ahead of defaults. |
| **Summary** | **9 scopes** | **31 proposed test cases** |

</details>

The plan surfaces nine source areas with thirty-one focused test ideas to exercise deterministic behavior, string processing, geometry preference wiring, type erasure semantics, UIKit helpers, and pluralization utilities across QizhKit.
