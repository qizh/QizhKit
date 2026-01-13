import SwiftSyntax
import SwiftSyntaxMacros
import QizhMacroKit

/// Implementation of the `docSwiftCode` macro.
///
/// This macro accepts a closure and produces a `DocumentationCodeBlock`
/// containing the source text of the closure body.  If the last argument is
/// not a closure, the macro returns an empty code block.  In this
/// placeholder implementation the entire closure syntax is captured via
/// `.description`.  Future versions should extract only the body of the
/// closure (excluding the braces and any parameters).
public struct DocSwiftCodeBlockMacro: ExpressionMacro {
    public static func expansion(
        of node: MacroExpansionExprSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        // Find the closure argument.
        guard let lastArg = node.argumentList.last?.expression,
              let closure = lastArg.as(ClosureExprSyntax.self) else {
            return ExprSyntax("DocumentationCodeBlock(language: .swift, value: "\"")")
        }
        // Extract the raw source of the closure.
        let closureSource = closure.description.replacingOccurrences(of: "\"", with: "\\\"")
        return ExprSyntax("DocumentationCodeBlock(language: .swift, value: \"\(closureSource)\")")
    }
}