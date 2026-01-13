import SwiftSyntaxMacros
import SwiftDiagnostics

/// Provides macros for generating documentation comments and sections.
///
/// The `@Doc` macro attaches generated DocC comments to a declaration.  It
/// accepts a title string, an optional `DocumentationConfiguration`, and a
/// variadic list of `DocumentationEntry` values describing the sections of
/// the documentation.  See `DocumentationEntry` and related types for
/// supported content.

@attached(declaration, names: arbitrary)
public macro Doc<each E: DocumentationEntry>(
  _ title: String,
  options: DocumentationConfiguration = .default,
  _ items: repeat each E
) = #externalMacro(module: "QizhMacroKitMacros", type: "DocGenerator")

/// Creates a bullet list documentation section.
///
/// Use this macro within `@Doc` to wrap a header and a list of documentation
/// entries into a `DocumentationSectionBulletList` value.  The `level`
/// parameter controls nested bullet indentation (optional).
@freestanding(expression)
public macro docBulletList<each E: DocumentationEntry>(
  _ title: String? = nil,
  level: UInt? = nil,
  _ items: repeat each E
) -> DocumentationSectionBulletList = #externalMacro(
    module: "QizhMacroKitMacros", type: "DocListMacro"
)

/// Converts a Swift closure into a code block for documentation.
///
/// Pass a closure containing Swift statements to this macro; it will extract
/// the closure body as a string and return a `DocumentationCodeBlock` with
/// language `.swift`.  The optional `title` and `level` arguments are
/// currently unused but provided for future extensions.
@freestanding(expression)
public macro docSwiftCode(
  _ title: String? = nil,
  level: UInt? = nil,
  _ codeBlock: () -> Void
) -> DocumentationCodeBlock = #externalMacro(
    module: "QizhMacroKitMacros", type: "DocSwiftCodeBlockMacro"
)