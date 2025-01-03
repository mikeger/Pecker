import Foundation
import SwiftSyntax

class SwiftSourceCollectVisitor: SyntaxVisitor {
    
    var sources: [SourceDetail] = []
    var sourceExtensions: [String: SourceDetail] = [:]
    private let context: CollectContext
    private var rules: [SourceCollectRule] = []
    
    init(context: CollectContext) {
        self.context = context
        self.rules = context.configuration.rules.compactMap { $0 as? SourceCollectRule }
        super.init(viewMode: .sourceAccurate)
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocation(syntax: node.name) {
            if skip(syntax: node, location: position) {
                return .visitChildren
            }
            collect(SourceDetail(name: node.name.text, sourceKind: .class, location: position))
        }
        return .visitChildren
    }
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocation(syntax: node.name) {
            if skip(syntax: node, location: position) {
                return .visitChildren
            }
            collect(SourceDetail(name: node.name.text, sourceKind: .struct, location: position))
        }
        return .visitChildren
    }
    
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let ps = node.signature.parameterClause.parameters.compactMap {
            $0.firstName.text
        }
        let function = Function(name: node.name.text, parameters: ps)
        if let position = findLocation(syntax: node.name) {
            if skip(syntax: node, location: position) {
                return .visitChildren
            }
            collect(SourceDetail(name: function.description, sourceKind: .function, location: position))
        }
        return .visitChildren
    }
    
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocation(syntax: node.name) {
            if skip(syntax: node, location: position) {
                return .visitChildren
            }
            collect(SourceDetail(name: node.name.text, sourceKind: .enum, location: position))
        }
        return .visitChildren
    }
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocation(syntax: node.name) {
            if skip(syntax: node, location: position) {
                return .visitChildren
            }
            collect(SourceDetail(name: node.name.text, sourceKind: .protocol, location: position))
        }
        return .visitChildren
    }
    
    override func visit(_ node: TypeAliasDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocation(syntax: node.name) {
            if skip(syntax: node, location: position) {
                return .visitChildren
            }
            collect(SourceDetail(name: node.name.text, sourceKind: .typealias, location: position))
        }
        return .visitChildren
    }
    
    override func visit(_ node: OperatorDeclSyntax) -> SyntaxVisitorContinueKind {
        if let position = findLocation(syntax: node.name) {
            if skip(syntax: node, location: position) {
                return .visitChildren
            }
            collect(SourceDetail(name: node.name.text, sourceKind: .operator, location: position))
        }
        return .visitChildren
    }
    
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        for token in node.extendedType.tokens(viewMode: .sourceAccurate) {
            if let position = findLocation(syntax: token) {
                let source = SourceDetail(name: token.text , sourceKind: .extension, location: position)
                sourceExtensions[source.identifier] = source
            }
        }
        return .visitChildren
    }
}

extension SwiftSourceCollectVisitor {
    
    func skip(syntax: IdentifierSyntax, location: SourceLocation) -> Bool {
        // Skip the symbol in blacklist
        if context.configuration.blacklistSymbols.contains(syntax.identifier.text) {
            return true
        }
        // Rules check
        if rules.contains(where: { $0.skip(syntax, location: location) }) {
            return true
        }
        return false
    }
    
    func collect(_ source: SourceDetail) {
        if !checkBlacklist(source: source) {
            sources.append(source)
        }
    }
    
    func findLocation(syntax: SyntaxProtocol) -> SourceLocation? {
        let position = context.sourceLocationConverter.location(for: syntax.positionAfterSkippingLeadingTrivia)
        return SourceLocation(path: context.filePath, line: position.line, column: position.column, offset: position.offset)
    }
}
