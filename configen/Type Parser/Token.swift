//
//  Token.swift
//  configen
//
//  Created by Suyash Srijan on 12/01/2020.
//  Copyright © 2020 The App Business. All rights reserved.
//

import Foundation

// TODO: Add ':' to support `Dictionary`
/// An enum that describes the kind of tokens we can parse
enum Token {
	/// `[`
	case lSquare
	/// `]`
	case rSquare
	/// An identifier for a type
	case identifier(String)

	/// Initialize a token from a `String`
	init?(rawValue: String) {
		if case .success = rawValue.match(regex: "\\[") {
			self = .lSquare
		} else if case .success = rawValue.match(regex: "\\]") {
			self = .rSquare
		} else if case let .success(value) = rawValue.match(regex: "[a-zA-Z][a-zA-Z0-9]*") {
			self = .identifier(value)
		} else {
			fatalError("Unhandled token")
		}
	}
}

extension Token {
	/// The length of the token
	var length: Int {
		switch self {
			case .lSquare, .rSquare:
				return 1
			case let .identifier(value):
				return value.count
		}
	}
}

extension Token: CustomStringConvertible {
	var description: String {
		switch self {
			case .lSquare:
				return "["
			case .rSquare:
				return "]"
			case let .identifier(value):
				return value
		}
	}
}

extension Token: Equatable {}
