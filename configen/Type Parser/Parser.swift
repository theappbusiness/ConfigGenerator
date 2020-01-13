//
//  Parser.swift
//  configen
//
//  Created by Suyash Srijan on 12/01/2020.
//  Copyright © 2020 The App Business. All rights reserved.
//

import Foundation

/// A class responsible for parsing a type
final class Parser {
	/// A map that contains known mappings from a name to a builtin type
	private let builtinTypeMap: [String: BuiltinType] = [
		"Bool": .bool,
		"String": .string,
		"Int": .int,
		"Double": .double,
		"URL": .url,
		"Any": .any
	]

	/// The tokens to parse
	private let tokens: [Token]

	/// The index of the current token. This is the token that the
	/// parser is currently looking at.
	private var currentTokenIndex = 0

	/// Initialize the parser with tokens that can be parsed to form a type
	init(tokens: [Token]) {
		self.tokens = tokens
	}

	/// Parse the tokens into a type
	func parse() throws -> BuiltinType {
		return try parseAny()
	}

	/// Parse a type
	// TODO: Parse 'Dictionary' type
	private func parseAny() throws -> BuiltinType {
		switch getCurrentToken() {
			case .lSquare:
				return try parseArray()
			case .rSquare:
				// We cannot parse a type that starts with an ']'
				throw Error.unexpectedToken(.rSquare, at: currentTokenIndex)
			case let .identifier(value):
				return builtinTypeMap[value] ?? .custom(value)
		}
	}

	/// Recursively parse a Swift array type with a built-in element type
	private func parseArray() throws -> BuiltinType {
		let stack: Stack<Token> = .init()
		var parsedIdentifier = ""
		var depth = 0

		while tokensAvailable() {
			if case .lSquare = getCurrentToken() {
				depth += 1
				stack.push(consumeToken())
				continue
			}

			if case .rSquare = getCurrentToken() {
				guard stack.peek() == .lSquare else {
					throw Error.unbalancedBracket(at: currentTokenIndex)
				}
				stack.pop()
				consumeToken()
				continue
			}

			parsedIdentifier = try parseIdentifier()
		}

		guard parsedIdentifier.isNotEmpty else {
			throw Error.typeNameNotFound
		}

		if let mappedType = builtinTypeMap[parsedIdentifier] {
			return .array(depth: depth, elementType: mappedType)
		}

		return .custom(parsedIdentifier)
	}

	/// Parse an identifier string
	private func parseIdentifier() throws -> String {
		if case let .identifier(name) = getCurrentToken() {
			consumeToken()
			return name
		}

		throw Error.unexpectedToken(getCurrentToken(), at: currentTokenIndex)
	}

	/// Get the current token that the parser is looking at
	private func getCurrentToken() -> Token {
		return tokens[currentTokenIndex]
	}

	/// Consume the current token and move to the next token
	@discardableResult
	private func consumeToken() -> Token {
		let prevToken = getCurrentToken()
		currentTokenIndex += 1
		return prevToken
	}

	/// Returns whether there are still tokens available for parsing
	private func tokensAvailable() -> Bool {
		return currentTokenIndex < tokens.count
	}
}

extension Parser {
	enum Error: Swift.Error, CustomStringConvertible {
		case unexpectedToken(Token, at: Int)
		case unbalancedBracket(at: Int)
		case typeNameNotFound

		var description: String {
			switch self {
				case let .unexpectedToken(token, index):
					return "Unexpected token '\(token)' at index '\(index)'"
				case let .unbalancedBracket(index):
					return "Unbalanced bracket at index '\(index)'"
				case .typeNameNotFound:
					return "Expected a type name, but found nothing"
			}
		}
	}
}
