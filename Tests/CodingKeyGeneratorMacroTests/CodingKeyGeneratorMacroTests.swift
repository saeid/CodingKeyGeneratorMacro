import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import CodingKeyGeneratorMacroMacros

let testMacros: [String: Macro.Type] = [
    "CodingKeyGen": CodingKeyGen.self,
]

final class CodingKeyGeneratorMacroTests: XCTestCase {
    func test_codingKeyMacro_withCustomValues() throws {
        assertMacroExpansion(
            #"""
            @CodingKeyGen([
            "name": "userValue",
            "id": "userid",
            "userName": "new_user"
            ])
            public struct MyCodableStruct: Codable {
                let name: String
                let id: Int
                let userName: String
            }
            """#,
            expandedSource:
            """
            public struct MyCodableStruct: Codable {
                let name: String
                let id: Int
                let userName: String

                enum CodingKeys: String, CodingKey {
                    case name = "userValue"
                    case id = "userid"
                    case userName = "new_user"
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_codingKeyMacro_withoutCustomValues() throws {
        assertMacroExpansion(
            #"""
            @CodingKeyGen()
            public struct MyCodableStruct: Codable {
                let name: String
                let id: Int
                let userName: String
            }
            """#,
            expandedSource:
            """
            public struct MyCodableStruct: Codable {
                let name: String
                let id: Int
                let userName: String

                enum CodingKeys: String, CodingKey {
                    case name
                    case id
                    case userName
                }
            }
            """,
            macros: testMacros
        )
    }
}
