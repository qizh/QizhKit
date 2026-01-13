import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import QizhMacroKit

/// Implementation of the `@Doc` macro.
///
/// This declaration macro attaches a generated documentation comment to the
/// annotated declaration.  It extracts the first argument as the title and
/// ignores all remaining arguments in this placeholder implementation.  The
/// final comment consists of a single line containing the title.
public struct DocGenerator: DeclarationMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingArguments context: inout some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Locate the annotated declaration.
        guard let parentDecl = node.parent?.parent else {
            return []
        }
        // Extract the arguments from the macro attribute.
        var title: String = ""
        if let argumentList = node.argument?.as(LabeledExprListSyntax.self) {
            // Find the first unlabeled argument and interpret it as a string literal.
            for arg in argumentList {
                if arg.label == nil, let stringLit = arg.expression.as(StringLiteralExprSyntax.self) {
                    // Concatenate segments to form the full title.
                    title = stringLit.segments.map { segment in
                        if let segment = segment as? StringSegmentSyntax {
                            return segment.content.text
                        }
                        return ""
                    }.joined()
                    break
                }
            }
        }
        // Build a basic documentation comment with the title on a single line.
        let docLines: [String]
        if !title.isEmpty {
            docLines = ["/// \(title)"]
        } else {
            docLines = ["///"]
        }
        // Attach the doc comment to the declaration using leading trivia.
        var declSyntax = DeclSyntax(parentDecl.asProtocol(DeclSyntaxProtocol.self)!)
        let leading = Trivia(pieces: docLines.map { .docLineComment($0 + "\n") })
        declSyntax = declSyntax.withLeadingTrivia(leading + declSyntax.leadingTrivia)
        return [declSyntax]
    }
}