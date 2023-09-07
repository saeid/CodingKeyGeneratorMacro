// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: arbitrary)
public macro CodingKeyGen<T>(
    properties: [PartialKeyPath<T>: String] = [:]
) = #externalMacro(
    module: "CodingKeyGeneratorMacroMacros",
    type: "CodingKeyGen"
)
