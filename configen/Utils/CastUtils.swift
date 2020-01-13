//
//  CastUtils.swift
//  configen
//
//  Created by Suyash Srijan on 13/01/2020.
//  Copyright © 2020 The App Business. All rights reserved.
//

import Foundation

final class CastUtils {
	/// Format a raw value of NSArray type to a String representation
	static func transformArrayToString(_ arrayType: BuiltinType, rawValue: Any) -> String {
		guard case let .array(_, elementType) = arrayType else {
			fatalError("Expected an array type, but found '\(arrayType.description)'")
		}
		let rawValueToConvert = castArray(rawValue as! NSArray, arrayElementType: elementType)
		var rawValueString = "\(rawValueToConvert)".trimmingCharacters(in: .whitespacesAndNewlines)
		// Special case: If we have an array of URLs, then we need to drop all
		// double quotes.
		if elementType == .url {
			rawValueString = rawValueString.filter { $0 != "\"" }
		}
		return rawValueString
	}

	/// Transform an NSArray to Swift Array
	private static func castArray(_ array: NSArray, arrayElementType: BuiltinType) -> Any {
		var temp: [Any] = []
		for index in 0..<array.count {
			if let item = array[index] as? NSArray {
				temp.append(castArray(item, arrayElementType: arrayElementType))
			} else {
				temp.append(castArrayElement(array[index], arrayElementType: arrayElementType))
			}
		}

		return temp
	}

	/// Cast a value to the given builtin type
	private static func castArrayElement(_ value: Any, arrayElementType: BuiltinType) -> Any {
		func emitFailedCastError() -> Never {
			fatalError("Cast from element of type '\(type(of: value))' to " +
				"type '\(arrayElementType.description)' is unsupported")
		}
		switch arrayElementType {
			case .string:
				return value as! String
			case .bool:
				return value as! Bool
			case .int:
				return value as! Int
			case .double:
				return value as! Double
			case .url:
				guard let str = value as? String, let _ = URL(string: str) else {
					emitFailedCastError()
				}
				return "URL(string: \(str))!"
			case .any:
				return value
			default:
				// TODO: Handle Data, Date, etc types
				emitFailedCastError()
		}
	}
}
