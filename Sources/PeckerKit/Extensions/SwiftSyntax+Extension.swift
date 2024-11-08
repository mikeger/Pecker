import Foundation
import SwiftSyntax

protocol InheritableSyntax {
    var inheritanceClause: InheritanceClauseSyntax? { get }
    func isInherited(from string: String) -> Bool
}

extension InheritableSyntax {
    func isInherited(from string: String) -> Bool {
        inheritanceClause?.inheritedTypes.contains(where: { $0.lastToken(viewMode: .sourceAccurate)?.text == string }) ?? false
    }
}

extension ClassDeclSyntax: InheritableSyntax {}
extension StructDeclSyntax: InheritableSyntax {}
extension EnumDeclSyntax: InheritableSyntax {}
extension ProtocolDeclSyntax: InheritableSyntax {}

protocol ModifierSyntax: SyntaxProtocol {
    var modifiers: DeclModifierListSyntax { get }
    func isPublic() -> Bool
}

extension ModifierSyntax {
    func searchParent<T: ModifierSyntax>() -> T? {
        var currentParent: SyntaxProtocol? = parent
        
        while currentParent != nil {
          if let decl = currentParent as? T {
            return decl
          }
          currentParent = currentParent?.parent
        }
        return nil
    }
}

extension ModifierSyntax {
    func isPublic() -> Bool {
        if modifiers.contains(where: {
            $0.name.tokenKind == .keyword(.public)
        }) {
            return true
        }
        if modifiers.contains(where: {
            $0.name.tokenKind == .keyword(.private) ||
            $0.name.tokenKind == .keyword(.internal) ||
            $0.name.tokenKind == .keyword(.fileprivate)
        }) {
            return false
        }
    
        if let extDel: ExtensionDeclSyntax = searchParent(),
           extDel.modifiers.contains(where: { $0.name.tokenKind == .keyword(.public) }) {
            return true
        }
        return false
    }
}

extension ClassDeclSyntax: ModifierSyntax {}
extension StructDeclSyntax: ModifierSyntax {}
extension EnumDeclSyntax: ModifierSyntax {}
extension ProtocolDeclSyntax: ModifierSyntax {}
extension FunctionDeclSyntax: ModifierSyntax {}
extension TypeAliasDeclSyntax: ModifierSyntax {}
extension ExtensionDeclSyntax: ModifierSyntax {}


protocol IdentifierSyntax: SyntaxProtocol {
    var identifier: TokenSyntax { get }
}

extension ClassDeclSyntax: IdentifierSyntax {}
extension StructDeclSyntax: IdentifierSyntax {}
extension EnumDeclSyntax: IdentifierSyntax {}
extension ProtocolDeclSyntax: IdentifierSyntax {}
extension FunctionDeclSyntax: IdentifierSyntax {}
extension TypeAliasDeclSyntax: IdentifierSyntax {}
extension OperatorDeclSyntax: IdentifierSyntax {}

extension TriviaPiece {
    public var comment: String? {
        switch self {
        case .spaces,
             .tabs,
             .verticalTabs,
             .formfeeds,
             .newlines,
             .carriageReturns,
             .carriageReturnLineFeeds,
             .backslashes,
             .pounds,
             .unexpectedText:
            return nil
        case .lineComment(let comment),
             .blockComment(let comment),
             .docLineComment(let comment),
             .docBlockComment(let comment):
            return comment
        }
    }
}
