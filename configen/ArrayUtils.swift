//
//  ArrayUtils.swift
//  configen
//
//  Created by Suyash Srijan on 13/01/2020.
//  Copyright © 2020 The App Business. All rights reserved.
//

import Foundation

final class ArrayUtils {
	enum Error: Swift.Error {
		case invalidArrayType
	}

	/// Check if this is a valid Array type by checking if the brackets are balanced
	static func isValidArrayType(_ rawType: String) -> Result<String, Error> {
		var stack: [Character] = []
		var elementNameChars: [Character] = []

		// A quick and simple check to see if this could *potentially* be an
		// Array type.
		guard rawType.first == .lSquare && rawType.last == .rSquare else {
			return .failure(.invalidArrayType)
		}

		// Okay, let's properly check if the brackets are balanced
		for character in rawType {
			if case .lSquare = character {
				stack.append(character)
				continue
			}

			if case .rSquare = character {
				guard stack.last == .lSquare else {
					return .failure(.invalidArrayType)
				}
				_ = stack.popLast()
				continue
			}

			// We're looking at something that is not a bracket. This is likely
			// the name of the array's element type (the innermost name if this is
			// a nested array). It can only be alphanumeric (i.e. String, UInt8, etc).
			if character.isLetter || character.isNumber {
				elementNameChars.append(character)
			}
		}

		// If we extracted the name of the element type and the brackets were
		// balanced, then this is a valid type.
		if !elementNameChars.isEmpty && stack.isEmpty {
			return .success(String(elementNameChars))
		}

		// Otherwise, either we're looking at a different type or the user
		// has made a mistake when writing the type name.
		return .failure(.invalidArrayType)
	}

	/// Format a raw value of NSArray type to a String representation
	static func transformArrayToString(_ arrayElementType: String, rawValue: Any) -> String {
		precondition(rawValue is NSArray, "Expected an 'NSArray', got '\(type(of: rawValue))'")
		let rawValueToConvert = castArray(rawValue as! NSArray, arrayElementType: arrayElementType)
		var rawValueString = "\(rawValueToConvert)".trimmingCharacters(in: .whitespacesAndNewlines)
		// Special case: If we have an array of URLs, then we need to drop all
		// double quotes.
		if arrayElementType == "URL" {
			rawValueString = rawValueString.filter { $0 != "\"" }
		}
		return rawValueString
	}

	/// Transform an NSArray to Swift Array by explicitly bridging each element.
	private static func castArray(_ array: NSArray, arrayElementType: String) -> Any {
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

	/// Cast a value to the given array element type
	private static func castArrayElement(_ value: Any, arrayElementType: String) -> Any {
		func emitFailedCastError() -> Never {
			fatalError("Cast from element of type '\(type(of: value))' to " +
				"type '\(arrayElementType)' is unsupported")
		}
		switch arrayElementType {
			case "String":
				return value as! String
			case "Bool":
				return value as! Bool
			case "Int":
				return value as! Int
			case "Double":
				return value as! Double
			case "URL":
				guard let str = value as? String, let _ = URL(string: str) else {
					emitFailedCastError()
				}
				return "URL(string: \(str))!"
			case "Any":
				return value
			default:
				// TODO: Handle Data, Date, etc types
				emitFailedCastError()
		}
	}
}
