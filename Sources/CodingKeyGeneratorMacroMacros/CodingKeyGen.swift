//
//  CodingKeyGen.swift
//
//
//  Created by Saeid Basirnia on 2023-09-06.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CodingKeyGen: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax,
        Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        do {
            let (structDecl, values) = try Helper.decode(
                of: node,
                attachedTo: declaration,
                in: context
            )
            let properties = Helper.getProperties(decl: structDecl)
            let generator = CodingKeyGenerator(
                properties: properties,
                values: values ?? []
            )

            let decl = generator
                .generate()
                .formatted()
                .as(EnumDeclSyntax.self)!

            return [
                DeclSyntax(decl)
            ]
        } catch {
            throw error
        }
    }
}

@main
struct CodingKeyGeneratorMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CodingKeyGen.self,
    ]
}
