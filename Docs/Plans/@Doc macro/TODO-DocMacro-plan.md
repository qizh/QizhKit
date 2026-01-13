Implementation Plan for @Doc and docSwiftCode Macros

Overview

This plan focuses on adding two new macros to QizhMacroKit:
	1.	@Doc – an attached declaration macro that generates DocC comments on a declaration.  It takes a title, an optional DocumentationConfiguration, and a variadic list of DocumentationEntry conforming values (bullet lists, known sections, code blocks, etc.) and synthesizes a full doc comment.
	2.	docSwiftCode – a freestanding expression macro that turns the body of a closure into a DocumentationCodeBlock.  This macro is analogous to #stringify, but accepts an entire closure and returns a structured value instead of a tuple.

The plan assumes Swift 6.2+ and follows the patterns described in AGENTS.md: macro declarations live in Sources/QizhMacroKit/ and implementations live in Sources/QizhMacroKitMacros/, with tests under Tests/.

Macro and Type Declarations

Create the following new public types in Sources/QizhMacroKit/DocumentationEntry.swift (or similar):
	•	public protocol DocumentationEntry: Sendable with generate(respecting options: DocumentationConfiguration) async throws -> String.
	•	public struct DocumentationConfiguration: OptionSet, Hashable, Sendable with fields maxColumns and detalization, plus nested Options and Detalization enumerations and a .default case.
	•	public struct DocumentationAtom: DocumentationEntry, ExpressibleByStringLiteral – holds a value and an optional depth, and generates a string with indentation based on depth.
	•	public struct DocumentationSectionBulletList: DocumentationEntry – holds an optional header, an array of DocumentationEntry items and an optional depth; its generate returns a “## header” (if present) followed by - ‑prefixed lines for each entry.
	•	public struct DocumentationKnownSection<E: DocumentationEntry>: DocumentationEntry – wraps another entry and annotates it with a Field enumeration (cases like .discussion, .parameters, .throws, .returns, etc.); its generate returns - FieldName:\n  <entry>.
	•	public struct DocumentationCodeBlock: DocumentationEntry – holds a language (enum) and a value string; its generate returns a fenced code block with the language identifier.

Add helper expression macros (skeletons for now) to build known sections (e.g. discussion, parameters, etc.) and bullet lists; these mirror the pseudo‑code you provided.

Macro Declarations

Add the following macro declarations under Sources/QizhMacroKit/Doc.swift:

```swift
@attached(declaration, names: arbitrary)
public macro Doc<each E: DocumentationEntry>(
  _ title: String,
  options: DocumentationConfiguration = .default,
  _ items: repeat each E
) = #externalMacro(module: "QizhMacroKitMacros", type: "DocGenerator")

@freestanding(expression)
public macro docBulletList<each E: DocumentationEntry>(
  _ title: String? = nil,
  level: UInt? = nil,
  _ items: repeat each E
) -> DocumentationSectionBulletList = #externalMacro(
    module: "QizhMacroKitMacros", type: "DocListMacro"
)

@freestanding(expression)
public macro docSwiftCode(
  _ title: String? = nil,
  level: UInt? = nil,
  _ codeBlock: () -> Void
) -> DocumentationCodeBlock = #externalMacro(
    module: "QizhMacroKitMacros", type: "DocSwiftCodeBlockMacro"
)
```

Register these macros in _QizhMacroKitMacro.swift by adding them to providingMacros.

Macro Implementations

Create the following generator files in Sources/QizhMacroKitMacros/:
	1.	DocGenerator.swift implementing DocGenerator: DeclarationMacro.  In its expansion method, parse the attribute’s arguments:
	•	The first unlabeled argument is the doc title.
	•	The optional options: argument configures DocumentationConfiguration (fall back to .default).
	•	The variadic remainder are DocumentationEntry values.  Because macro parameters are type‑erased, you may need to accept them as expressions and synthesise code to call .generate at compile time, or directly build the doc comment string within the macro.  Use leadingTrivia on the declaration to attach the generated ///‑prefixed lines ￼.
A minimal first pass can iterate through the provided items and insert placeholder comment lines like /// (TODO: generate from entry), leaving the real generation for a follow‑up agent.
	2.	DocListMacro.swift implementing a freestanding expression macro that wraps its inputs into a DocumentationSectionBulletList.  It should produce DocumentationSectionBulletList(header: <title>, items: [items], depth: level).
	3.	DocSwiftCodeBlockMacro.swift implementing a freestanding expression macro that accepts a closure.  The macro should:
	•	Ensure exactly one closure argument and report a diagnostic otherwise.
	•	Downcast the argument to ClosureExprSyntax and extract the closure’s body as a string.  You can access a syntax node’s source text via .description or .withoutTrivia().description.  Attach that string to a DocumentationCodeBlock initialiser with language: .swift.
	•	In future work, preserve indentation and remove the surrounding braces.
If closure stringification cannot be fully implemented within the current macro system (e.g. due to limitations with capturing closure bodies), provide diagnostic stubs that instruct the user to use a single expression or file a bug.  See Swift forum advice on using leadingTrivia for attaching comments ￼.

Partial Implementation Notes
	•	You can consult the existing stringify macro in QizhMacroKit for patterns on capturing source text of an expression.
	•	Because macros run at compile time, asynchronous generate(respecting:) methods cannot be executed during macro expansion.  Instead, generate the doc comment string directly in the macro or synthesise runtime code that calls .generate.
	•	When building doc comment strings, remember to start each line with /// and include blank comment lines to separate sections.

Tests

Create a new test target DocMacroTests under Tests/DocMacroTests.  Following the existing testing pattern, write tests that illustrate expected macro behaviour.  These tests will not pass until the macros are fully implemented but will serve as documentation and acceptance criteria.

Example test file (Tests/DocMacroTests/DocMacroTests.swift):

```swift
#if os(macOS)
import Testing
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import QizhMacroKit
@testable import QizhMacroKitMacros

@Suite("Doc macro")
struct DocMacroTests {
  let macros: [String: any Macro.Type] = [
    "Doc": DocGenerator.self,
    "docBulletList": DocListMacro.self,
    "docSwiftCode": DocSwiftCodeBlockMacro.self,
  ]

  @Test("simple constant with bullet list and code block")
  func plusCharDoc() {
    assertMacroExpansion(
      #"""
      @Doc("`+`",
        docBulletList("Unicode", "+", "`U+002B`"),
        docSwiftCode {
          Character("+")
        }
      )
      static let plusChar: Character = "+"
      """#,
      expandedSource:
      #"""
      /// `+`
      ///
      /// ## Unicode
      /// - +
      /// - `U+002B`
      ///
      /// - Returns:
      ///   ```swift
      ///   Character("+")
      ///   ```
      static let plusChar: Character = "+"
      """#,
      macros: macros
    )
  }

  @Test("docSwiftCode produces code block")
  func docSwiftCodeValue() {
    let block = docSwiftCode("Example") {
      let x = 1
      print(x)
    }
    #expect(block.value.contains("let x = 1"))
    #expect(block.language == .swift)
  }
}
#endif
```

These tests express what the final macro should produce.  They will initially fail but serve as clear guidance for the implementation.

Implementation Task for a Third‑Party AI Agent

Create a new task file (e.g. TODO-DocMacro.md) describing the work required to complete the macros.  Include:
	•	A checklist of the remaining functions and code paths to implement in each macro generator.
	•	Guidance on how to parse macro arguments and build doc comments using SwiftSyntax.
	•	Pointers to helpful resources (e.g. the Swift forum advice on attaching comments via leadingTrivia ￼).
	•	Instructions to update _QizhMacroKitMacro.swift to register the new macros.
	•	A reminder to run swift test and ensure all DocMacroTests pass before submission.
	•	A section describing any known limitations (such as potential issues with capturing complex closures) and recommended workarounds.

⸻

Summary

This plan sets up the structure for the @Doc and docSwiftCode macros in QizhMacroKit.  It introduces the necessary protocols and helper types, declares the macros, provides skeleton implementations, writes high‑level tests, and defines a clear path for a future contributor to complete the implementation.  The tests and TODO file will guide further development and ensure that the final macros behave as intended.

