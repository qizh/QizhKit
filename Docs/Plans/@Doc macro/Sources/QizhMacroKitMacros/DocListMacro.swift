import SwiftSyntax
import SwiftSyntaxMacros
import QizhMacroKit

/// Implementation of the `docBulletList` macro.
///
/// This expression macro constructs a `DocumentationSectionBulletList` value
/// from the provided title and items.  In this placeholder implementation,
/// only the optional title argument is parsed; the items are ignored and an
/// empty list is returned.  Future implementations should wrap each item
/// into a `DocumentationEntry` value.
public struct DocListMacro: ExpressionMacro {
    public static func expansion(
        of node: MacroExpansionExprSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        // Determine the header string from the first argument if present.
        let args = node.argumentList
        var headerLiteral: ExprSyntax = ExprSyntax(StringLiteralExprSyntax(content: ""))
        if let first = args.first, first.label == nil {
            if let string = first.expression.as(StringLiteralExprSyntax.self) {
                headerLiteral = ExprSyntax(string)
            }
        }
        // Construct a placeholder call to DocumentationSectionBulletList with no items.
        let call = "DocumentationSectionBulletList(header: \(headerLiteral), items: [])"
        return ExprSyntax(SyntaxFactory.makeIdentifierExpr(
            identifier: SyntaxFactory.makeIdentifier(call),
            declNameArguments: nil
        ))
    }
}