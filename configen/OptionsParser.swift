//
//  OptionsParser.swift
//  configen
//
//  Created by Dónal O'Brien on 10/08/2016.
//  Copyright © 2016 The App Business. All rights reserved.
//

import Foundation

final class OptionsParser {

  let appName: String
  let inputPlistFilePath: String
  let inputHintsFilePath: String
  let outputClassName: String
  let outputClassDirectory: String
  let isObjC: Bool

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
  }

  lazy var plistDictionary: [String: AnyObject] = { [unowned self] in

    let inputPlistFilePathURL = URL(fileURLWithPath: self.inputPlistFilePath)
    guard let data = try? Data(contentsOf: inputPlistFilePathURL) else {
      fatalError("No data at path: \(self.inputPlistFilePath)")
    }

    guard let plistDictionary = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: AnyObject] else {
      fatalError("Failed to create plist")
    }

    return plistDictionary
    }()

  lazy var hintsDictionary: [String: String] = { [unowned self] in
    guard let hintsString = try? String(contentsOfFile: self.inputHintsFilePath, encoding: String.Encoding.utf8) else {
      fatalError("No data at path: \(self.inputHintsFilePath)")
    }

    var hintsDictionary = [String: String]()

    let hintLines = hintsString.components(separatedBy: CharacterSet.newlines)
    for hintLine in hintLines where hintLine.trimmed.count > 0 {
      let hints = hintLine.components(separatedBy: CharacterSet(charactersIn: ":")).map { $0.trimmed }
      guard hints.count == 2 else {
        fatalError("Expected \"variableName : Type\", instead of \"\(hintLine)\"")
      }
      let (variableName, type) = (hints[0], hints[1])
      hintsDictionary[variableName] = type
    }

    return hintsDictionary
    }()
}
