//
//  BuiltinType.swift
//  configen
//
//  Created by Suyash Srijan on 12/01/2020.
//  Copyright © 2020 The App Business. All rights reserved.
//

import Foundation

// TODO: Add support for `Dictionary`
/// A type that is supported by configen
enum BuiltinType {
	/// The `Bool` type
	case bool
	/// The `String` type
	case string
	/// The `Int` type
	case int
	/// The `Double` type
	case double
	/// The `URL` type
	case url
	/// The `Any` type
	case any
	/// The `Array` type, with `depth`  which is number of brackets and an `elementType` which
	/// is the type of the array's `Element`. This can be recursive.
	indirect case array(depth: Int, elementType: BuiltinType)
	/// A custom type not supported by configen out of the box
	case custom(String)
}

extension BuiltinType: CustomStringConvertible {
	var description: String {
		switch self {
			case .bool:
				return "Bool"
			case .string:
				return "String"
			case .double:
				return "Double"
			case .url:
				return "URL"
			case .int:
				return "Int"
			case .any:
				return "Any"
			case let .custom(value):
				return value
			case let .array(depth, elementType):
				let prefixBrackets = Array(repeating: "[", count: depth).joined()
				let suffixBrackets = Array(repeating: "]", count: depth).joined()
				let toJoin = [prefixBrackets, elementType.description, suffixBrackets]
				return toJoin.joined()
		}
	}
}

extension BuiltinType: Equatable {}
