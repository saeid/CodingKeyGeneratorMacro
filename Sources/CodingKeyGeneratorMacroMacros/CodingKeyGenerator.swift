//
//  CodingKeyGenerator.swift
//
//
//  Created by Saeid Basirnia on 2023-09-06.
//

import SwiftSyntax

struct CodingKeyGenerator {
    enum Strategy {
        case `default`(String)
        case custom(String, String)

        func enumCaseElementSyntax() -> EnumCaseElementSyntax {
            switch self {
            case .default(let value):
                EnumCaseElementSyntax(
                    name: .identifier(value)
                )
            case .custom(let value, let customValue):
                EnumCaseElementSyntax(
                    name: .identifier(value),
                    rawValue: InitializerClauseSyntax(
                        equal: .equalToken(),
                        value: StringLiteralExprSyntax(content: customValue)
                    )
                )
            }
        }
    }

    private let properties: [String]
    private let values: Values

    init(
        properties: [String],
        values: Values
    ) {
        self.properties = properties
        self.values = values
    }

    func generate() -> EnumDeclSyntax {
        EnumDeclSyntax(
            name: .identifier("CodingKeys"),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(
                    type: TypeSyntax(
                        stringLiteral: "String"
                    )
                )
                InheritedTypeSyntax(
                    type: TypeSyntax(
                        stringLiteral: "CodingKey"
                    )
                )
            },
            memberBlockBuilder: {
                MemberBlockItemListSyntax(
                    generateStrategy().map { strategy in
                        MemberBlockItemSyntax(
                            decl: EnumCaseDeclSyntax(
                                elements: EnumCaseElementListSyntax(
                                    arrayLiteral: strategy.enumCaseElementSyntax()
                                )
                            )
                        )
                    }
                )
            }
        )
    }

    private func hasCustomValue(for property: String) -> Bool {
        return values.contains(where: { (key, _) in
            guard let key = key.first?.component else { return false }
            return "\(key)" == "\(property)"
        })
    }

    private func getStrategy(for property: String) -> Strategy {
        guard let item = values.first(where: { (key, value) in
            guard let component = key.first?.component else {
                return false
            }
            return "\(component)" == property
        }) else { return .default(property) }
        return .custom(property, item.1.text)
    }

    private func generateStrategy() -> [Strategy] {
        properties.map { property in
            guard hasCustomValue(for: property) else {
                return .default(property)
            }
            return getStrategy(for: property)
        }
    }
}
