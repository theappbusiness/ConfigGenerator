//
//  OptionsParser.swift
//  configen
//
//  Created by Dónal O'Brien on 10/08/2016.
//  Copyright © 2016 The App Business. All rights reserved.
//

import Foundation

final class OptionsParser {
	struct Hint {
		let variableName: String
		let type: BuiltinType
	}

	typealias PlistDictionary = [String: Any]

	let appName: String
	let inputPlistFilePath: String
	let inputHintsFilePath: String
	let outputClassName: String
	let outputClassDirectory: String
	let isObjC: Bool

	private(set) var plistDictionary: PlistDictionary = [:]
	private(set) var sortedHints: [Hint] = []

	init(appName: String) {
		let cli = CommandLineKit()
		let inputPlistFilePath = StringOption(shortFlag: "p", longFlag: "plist-path", required: true, helpMessage: "Path to the input plist file")
		let inputHintsFilePath = StringOption(shortFlag: "h", longFlag: "hints-path", required: true, helpMessage: "Path to the input hints file")
		let outputClassName = StringOption(shortFlag: "n", longFlag: "class-name", required: true, helpMessage: "The output config class name")
		let outputClassDirectory = StringOption(shortFlag: "o", longFlag: "output-directory", required: true, helpMessage: "The output config class directory")
		let useObjc = BoolOption(shortFlag: "c", longFlag: "objective-c", helpMessage: "Whether to generate Objective-C files instead of Swift")
		cli.addOptions(inputPlistFilePath, inputHintsFilePath, outputClassName, outputClassDirectory, useObjc)

		do {
			try cli.parse()
		} catch {
			cli.printUsage(error)
			fatalError()
		}

		self.appName = appName
		self.inputPlistFilePath = inputPlistFilePath.value!
		self.inputHintsFilePath = inputHintsFilePath.value!
		self.outputClassName = outputClassName.value!
		self.outputClassDirectory = outputClassDirectory.value!
		self.isObjC = useObjc.value
		self.plistDictionary = parsePlistDictionary()
		self.sortedHints = parseAndSortHints()
	}

	private func parsePlistDictionary() -> PlistDictionary {
		let inputPlistFilePathURL = URL(fileURLWithPath: inputPlistFilePath)
		guard let data = try? Data(contentsOf: inputPlistFilePathURL) else {
			fatalError("No data at path: \(inputPlistFilePath)")
		}

		let parsedDict = try? PropertyListSerialization.propertyList(from: data, format: nil)
		guard let plistDictionary = parsedDict as? PlistDictionary else {
			fatalError("Failed to create a plist dictionary from value of type \(type(of: parsedDict))")
		}

		return plistDictionary
	}

	private func parseAndSortHints() -> [Hint] {
		guard let hintsString = try? String(contentsOfFile: inputHintsFilePath, encoding: .utf8) else {
			fatalError("No data at path: \(inputHintsFilePath)")
		}

		var hints: [Hint] = []
		let hintLines = hintsString.components(separatedBy: .newlines)
		for hintLine in hintLines where hintLine.trimmed.isNotEmpty {
			let separatedHints = hintLine.components(separatedBy: ":").map { $0.trimmed }
			precondition(separatedHints.count == 2, "Expected \"variableName : Type\", instead of \"\(hintLine)\"")
			let variableName = separatedHints[0]
			let variableType = parseType(rawTypeName: separatedHints[1].trimmed)
			hints.append(.init(variableName: variableName, type: variableType))
		}

		return hints.sorted(by: <)
	}

	private func parseType(rawTypeName: String) -> BuiltinType {
		do {
			let lexer = Lexer(with: rawTypeName)
			let tokens = lexer.tokenize()
			let parser = Parser(tokens: tokens)
			return try parser.parse()
		} catch {
			fatalError("Unable to parse type: \(error)")
		}
	}
}

extension OptionsParser.Hint: Comparable {
	static func < (lhs: OptionsParser.Hint, rhs: OptionsParser.Hint) -> Bool {
		return lhs.variableName < rhs.variableName
	}
}
