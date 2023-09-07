// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: arbitrary)
public macro CodingKeyGen(
    properties: [String: String] = [:]
) = #externalMacro(
    module: "CodingKeyGeneratorMacroMacros",
    type: "CodingKeyGen"
)
