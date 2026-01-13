#if os(macOS)
import Testing
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import QizhMacroKit
@testable import QizhMacroKitMacros

/// Tests for the `@Doc` and related macros.
///
/// These tests will not pass until the macros are fully implemented.  They
/// nevertheless describe the intended behaviour and serve as executable
/// documentation for future contributors.  When implementing the macros,
/// make sure to register `DocGenerator`, `DocListMacro` and
/// `DocSwiftCodeBlockMacro` in `_QizhMacroKitMacro.swift`.
@Suite("Doc macro")
struct DocMacroTests {
    // Dictionary mapping macro names to their implementation types.
    // This dictionary is passed to `assertMacroExpansion` to ensure the
    // correct macro implementations are invoked.
    let macros: [String: any Macro.Type] = [
        "Doc": DocGenerator.self,
        "docBulletList": DocListMacro.self,
        "docSwiftCode": DocSwiftCodeBlockMacro.self,
    ]

    /// Ensures that a simple `@Doc` annotation attaches a header, bullet list
    /// section and returns section to a constant declaration.
    @Test("Simple constant documentation")
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
            """#, // End of source
            expandedSource: #"""
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
            """#, // End of expected
            macros: macros
        )
    }

    /// Ensures that `docSwiftCode` captures a closure body into a
    /// `DocumentationCodeBlock` value.  The language must be `.swift` and
    /// the value string should contain the code of the closure body.
    @Test("docSwiftCode captures closure body")
    func codeBlockCapture() {
        let block = docSwiftCode("Example") {
            let x = 1
            print(x)
        }
        #expect(block.language == .swift)
        #expect(block.value.contains("let x = 1"))
        #expect(block.value.contains("print(x)"))
    }
}
#endif