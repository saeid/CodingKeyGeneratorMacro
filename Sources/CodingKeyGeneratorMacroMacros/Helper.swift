//
//  File.swift
//  
//
//  Created by Saeid Basirnia on 2023-09-06.
//

import SwiftSyntax
import SwiftSyntaxMacros

public typealias Values = [String: String]

struct Helper {
    static func getProperties(decl: StructDeclSyntax) -> [String] {
        return decl
            .memberBlock
            .members
            .map(\.decl)
            .reduce(into: [String]()) { result, decl in
                guard let variableDecl = decl.as(VariableDeclSyntax.self) else {
                    return
                }
                let properties = variableDecl
                    .bindings
                    .compactMap {
                        $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                    }
                return result.append(contentsOf: properties)
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

        guard let dictionaryElements = dictionaryElements else {
            return (structDecl, nil)
        }
        let dictionaryValues = dictionaryElements.reduce(into: [String: String]()) { result, element in
            guard let key = element.key.as(StringLiteralExprSyntax.self),
                  let value = element.value.as(StringLiteralExprSyntax.self) else {
                result["name"] = "oh_no"
                return
            }
            result[key.string] = value.string
        }
        return (structDecl, dictionaryValues)
    }
}

fileprivate extension StringLiteralExprSyntax {
    var string: String {
        segments
            .compactMap { $0.as(StringSegmentSyntax.self) }
            .map(\.content.text)
            .joined()
    }
}
