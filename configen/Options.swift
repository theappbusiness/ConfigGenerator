//
//  Options.swift
//  configen
//
//  Created by John Sanderson on 22/07/2020.
//  Copyright © 2020 The App Business. All rights reserved.
//

import Foundation
import ArgumentParser

struct Options {

    typealias Hint = (variableName: String, type: String)

    let appName: String
    let inputPlistFilePath: String
    let inputHintsFilePath: String
    let outputClassName: String
    let outputClassDirectory: String

    func plistDictionary() throws -> [String: AnyObject] {
        let inputPlistFilePathURL = URL(fileURLWithPath: inputPlistFilePath)
        let data = try Data(contentsOf: inputPlistFilePathURL)
        let propertyList = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        guard let plistDictionary = propertyList as? [String: AnyObject] else {
            throw ValidationError("Failed to create plist from path: \(inputPlistFilePath)")
        }
        return plistDictionary
    }

    func sortedHints() throws -> [Hint] {
        let hintsString = try String(contentsOfFile: inputHintsFilePath, encoding: String.Encoding.utf8)
        var hints = [Hint]()
        let hintLines = hintsString.components(separatedBy: CharacterSet.newlines)
        for hintLine in hintLines where hintLine.trimmed.count > 0 {
            let separatedHints = hintLine.components(separatedBy: CharacterSet(charactersIn: ":")).map { $0.trimmed }
            guard separatedHints.count == 2 else {
                throw ValidationError("Expected \"variableName : Type\", instead of \"\(hintLine)\"")
            }
            hints.append(Hint(variableName: separatedHints[0], type: separatedHints[1]))
        }
        return hints.sorted(by: <)
    }
}
