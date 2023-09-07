//
//  File.swift
//  
//
//  Created by Saeid Basirnia on 2023-09-06.
//

import SwiftSyntax
import SwiftSyntaxMacros

public typealias Values = [(KeyPathComponentListSyntax, TokenSyntax)]

struct Helper {
    static func getProperties(decl: StructDeclSyntax) -> [String] {
        return decl.memberBlock.members.map(\.decl)
            .reduce([String]()) { result, decl -> [String] in
                guard let variableDecl = decl.as(VariableDeclSyntax.self) else {
                    return result
                }
                let properties = variableDecl.bindings.compactMap { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                }
                return result + properties
            }
    }

    static func decode(
        of attribute: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> (StructDeclSyntax, Values?) {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw CodingKeyGeneratorError.requiresStruct
        }

        let dictionaryElements = declaration.attributes.first?.as(AttributeSyntax.self)?
            .arguments?.as(LabeledExprListSyntax.self)?
            .first?.expression.as(DictionaryExprSyntax.self)?
            .content.as(DictionaryElementListSyntax.self)

        let stringLiteralExpr = dictionaryElements?
            .compactMap {
                $0.value.as(StringLiteralExprSyntax.self)
            }
        let keyPathExpr = dictionaryElements?
            .compactMap {
                $0.key.as(KeyPathExprSyntax.self)
            }
        guard let keyPathSyntax = getKeyPathComponentList(keyPathExpr),
              let stringSegmentSyntax = getStringSegmentSyntax(stringLiteralExpr) else {
            return (structDecl, nil)
        }
        let tokenSyntax = stringSegmentSyntax.compactMap { $0.content }
        let values = zip(keyPathSyntax, tokenSyntax).map { $0 }
        return (structDecl, values)
    }

    private static func getKeyPathComponentList(_ expr: [KeyPathExprSyntax]?) -> [KeyPathComponentListSyntax]? {
        expr?.compactMap { $0.components }
    }

    private static func getStringSegmentSyntax(_ expr: [StringLiteralExprSyntax]?) -> [StringSegmentSyntax]? {
        expr?
            .compactMap {
                $0.segments.first?.as(StringSegmentSyntax.self)
            }
    }
}
