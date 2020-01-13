//
//  StringExtensions.swift
//  configen
//
//  Created by Suyash Srijan on 12/01/2020.
//  Copyright © 2020 The App Business. All rights reserved.
//

import Foundation

extension String {
	mutating func replace(token: String, withString string: String) {
		self = replacingOccurrences(of: token, with: string)
	}

	var isNotEmpty: Bool {
		return !isEmpty
	}

	var trimmed: String {
		return (self as NSString).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}

	func match(regex: String) -> Result<String, Error> {
		do {
			let regex = try NSRegularExpression(pattern: "^\(regex)")
			let results = regex.matches(in: self, range: NSRange(startIndex..., in: self))
			let matchedString = results.map { String(self[Range($0.range, in: self)!]) }.first
			if let matchedString = matchedString, matchedString.isNotEmpty {
				return .success(matchedString)
			}
			return .failure(RegexError.noMatchFound)
		} catch let error {
			return .failure(error)
		}
	}

	enum RegexError: Error {
		case noMatchFound
	}
}
