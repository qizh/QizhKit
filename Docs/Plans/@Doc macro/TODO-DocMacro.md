# TODO: Complete the Doc macros implementation

This task file outlines the steps required to finish the `@Doc` and
`docSwiftCode` macros and to integrate them into the QizhMacroKit project.

## Goals

1. Implement the attached declaration macro `@Doc` so that it synthesises
   DocC comments using the provided title, configuration options, and
   variadic `DocumentationEntry` values.
2. Implement the freestanding expression macros `docBulletList` and
   `docSwiftCode` to construct list and code block documentation entries.
3. Provide support types (`DocumentationEntry`, `DocumentationAtom`,
   `DocumentationSectionBulletList`, `DocumentationKnownSection`, and
   `DocumentationCodeBlock`) with proper behaviour for generating Markdown
   fragments.
4. Register the macros in `_QizhMacroKitMacro.swift` so they are visible to
   the test harness.
5. Make the tests in `Tests/DocMacroTests/DocMacroTests.swift` pass.

## Implementation Notes

### DocumentationEntry types

The file `Sources/QizhMacroKit/DocumentationEntry.swift` defines the
protocols and structs used to build documentation fragments.  Ensure these
types produce correct Markdown when their `generate` method is invoked.  In
particular, nested bullet lists should respect their `depth` property,
`DocumentationKnownSection` should capitalise the field name and prefix
``- FieldName:`` on its own line, and `DocumentationCodeBlock` should wrap
its `value` in a fenced code block with the specified language.

### DocGenerator macro

Currently, `DocGenerator` is a placeholder.  To complete it:

1. Parse the macro arguments from the `AttributeSyntax`:
   - The first argument (no label) is the title string.
   - The optional `options:` parameter is a `DocumentationConfiguration`.
   - The remaining variadic arguments are arbitrary `DocumentationEntry` values.
2. Build a list of documentation lines:
   - Start with `/// <title>` on its own line.
   - Insert a blank `///` line between sections.
   - For each `DocumentationEntry`, call `generate(respecting:)` at
     compile time if possible and append the result (split into lines and
     prefaced with `/// `).
3. Combine the lines and insert them as leading trivia on the annotated
   declaration.  Use `Trivia.pieces` with `.docLineComment` to build the
   leading trivia.  See the Swift forums for guidance on attaching trivia
   comments【470321731022632†L16-L36】.
4. Return the modified declaration from `expansion`.

### DocListMacro

The `DocListMacro` stub returns an empty list.  You should parse the
arguments of the macro expansion expression:

1. The first parameter (if present) is the optional title.  It may be
   omitted or provided as `nil`.
2. The second parameter is the optional `level` (depth).  If omitted,
   default to `nil`.
3. All remaining parameters are items conforming to `DocumentationEntry`.

Create an `ArrayExprSyntax` containing these items.  If an argument is
a plain string literal, wrap it in a call to `DocumentationAtom`.  Then
construct and return a call expression:

```swift
DocumentationSectionBulletList(
    header: <title>,
    items: [<items>],
    depth: <level>
)
```

### DocSwiftCodeBlockMacro

The `DocSwiftCodeBlockMacro` stub currently captures the entire closure
syntax.  To complete it:

1. Ensure exactly one closure argument is accepted.  Emit a diagnostic if
   the macro is called with no closure or with more than one argument.
2. Use `ClosureExprSyntax` to inspect the closure.  Extract the code from
   the closure’s body (statements) without the enclosing braces.  You may
   call `.statements.description` on the body to get the raw text of the
   statements.  Remove any trailing trivia and normalise indentation.
3. Escape double quotes within the extracted string so it can be passed as
   a Swift string literal.
4. Return `DocumentationCodeBlock(language: .swift, value: "<extracted>")` as
   an expression syntax node.

### Tests

The tests in `DocMacroTests.swift` illustrate the desired behaviour.  They
use `assertMacroExpansion` to verify compile‑time expansion and `#expect`
assertions to verify runtime behaviour.  After implementing the macros,
run `swift test` and adjust your implementation until these tests pass.

## Caveats

- Swift macros cannot execute asynchronous code during expansion.  Do not call
  `.generate` on `DocumentationEntry` values at runtime.
- The macros must be registered in `_QizhMacroKitMacro.swift` as described
  in `AGENTS.md`.  Without registration, the tests will not find your
  macros.

---

By following these guidelines and completing the items above, you will
provide QizhMacroKit with a robust documentation generation system.