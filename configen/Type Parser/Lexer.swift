//
//  Lexer.swift
//  configen
//
//  Created by Suyash Srijan on 12/01/2020.
//  Copyright © 2020 The App Business. All rights reserved.
//

import Foundation

/// A struct responsible for performing lexical analysis on the input string
struct Lexer {
	/// The input string that contains raw type string.
	private var input: String
	/// The initializer
	init(with input: String) {
		self.input = input
	}

	/// Generate a list of tokens from the input
	func tokenize() -> [Token] {
		var tokens: [Token] = []
		var tempInput = input

		while tempInput.count > 0 {
			if let token = Token(rawValue: tempInput) {
				tokens.append(token)

				let length = token.length
				let range = tempInput.index(tempInput.startIndex, offsetBy: length)
				tempInput = String(tempInput[range...])
				continue
			}

			let index = tempInput.index(after: tempInput.startIndex)
			tempInput = String(tempInput[index...])
		}

		return tokens
	}
}
