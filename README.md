# CodingKeyGeneratorMacro
Swift macro to add CodingKeys to structs with supports for setting custom values for CodingKey keys.

## Installation
```Swift
.package(url: "https://github.com/saeid/CodingKeyGeneratorMacro", branch: "main")
```

## Usage

For providing custom keys, the goal is to support KeyPath to provide a type-safe api but there are issues with this approach. see [limitation](#Limitation) section.  
The implementation for this is in branch **keypath**.

### With custom keys
```Swift
@CodingKeyGen([
	"name": "userValue",
	"id": "userid",
	"userName": "new_user"
])
public struct MyStruct {
    let name: String
    let id: Int
    let userName: String
}
// Will be expanded to:
public struct MyStruct {
    let name: String
    let id: Int
    let userName: String

    enum CodingKeys: String, CodingKey {
        case name = "userValue"
        case id = "userid"
        case userName = "new_user"
    }
}
```
### Without custom keys
```Swift
@CodingKeyGen()
public struct MyCodableStruct: Codable {
    let name: String
    let id: Int
    let userName: String
}
// Will be expanded to:
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
```

## Limitation
In current state @attached macros have bug/limitation which doesn't allow to use a reference of the type in macro's argument list. It results to *Circular reference resolving attached macro* error. 

## Licence
CodingKeyGeneratorMacro is available under the MIT license. See the [LICENSE.txt](https://github.com/saeid/CodingKeyGeneratorMacro/blob/main/LICENSE) file for more info.
