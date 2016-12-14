//
//  main.swift
//  configen
//
//  Created by Sam Dods on 29/09/2015.
//  Copyright © 2015 The App Business. All rights reserved.
//

import Foundation

extension String {
  var trimmed: String {
    return (self as String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }
}

let arguments = CommandLine.arguments
guard arguments.count == 5 else {
  fatalError("usage: \(arguments.first!) <inputPlistFilePath> <inputHintsFilePath> <outputClassName> <outputClassDirectory>")
}

let inputPlistFilePath = arguments[1]
let inputHintsFilePath = arguments[2]
let outputClassName = arguments[3]
let outputClassDirectory = arguments[4]
let outputClassFileName = "\(outputClassDirectory)/\(outputClassName).swift"

guard let inputPlistFilePathURL = URL(string: "file://\(inputPlistFilePath)"),
  let data = try? Data(contentsOf: inputPlistFilePathURL) else {
  fatalError("No data at path: \(inputPlistFilePath)")
}

guard let plistDictionary = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? Dictionary<String, AnyObject> else {
  fatalError()
}

guard let hintsString = try? String(contentsOfFile: inputHintsFilePath, encoding: String.Encoding.utf8) else {
  fatalError("No data at path: \(inputHintsFilePath)")
}

var hintsDictionary = Dictionary<String, String>()

let hintLines = hintsString.components(separatedBy: CharacterSet.newlines)
for hintLine in hintLines where hintLine.trimmed.characters.count > 0 {
  let hints = hintLine.components(separatedBy: CharacterSet(charactersIn: ":")).map { $0.trimmed }
  guard hints.count == 2 else {
    fatalError("Expected \"variableName : Type\", instead of \"\(hintLine)\"")
  }
  let (variableName, type) = (hints[0], hints[1])
  hintsDictionary[variableName] = type
}

var requiresFoundation = false
var outputString = ""

for (variableName, type) in hintsDictionary {
  guard let value = plistDictionary[variableName] else {
    fatalError("No configuration setting for variable name: \(variableName)")
  }
  
  var line = ""
  
  switch (type) {
    case ("Double"):
      line = "\(variableName): Double = \(Double(value as! NSNumber))"
    
    case ("Int"):
      line = "\(variableName): Int = \(Int(value as! NSNumber))"
      
    case ("String"):
      line = ("\(variableName): String = \"\(value as! String)\"")
      
    case ("Bool"):
      let boolString = value as! Bool ? "true" : "false"
      line = "\(variableName): Bool = \(boolString)"
      
    case ("URL"):
      requiresFoundation = true
      let url = URL(string: value as! String)!
      guard url.host != nil else {
        fatalError("Found URL without host: \(url) for setting: \(variableName)")
      }
      line = "\(variableName): URL = URL(string: \"\(value)\")!"
      
    default:
      guard let stringValue = value as? String else {
        fatalError("Value (\(value)) must be a string in order to be used by custom type \(type)")
      }
      line = "\(variableName): \(type) = \(stringValue)"
  }
  
  outputString.append("\n  static let " + line + "\n")
}

let appName = (arguments.first! as NSString).lastPathComponent
let headerComment = "// auto-generated by \(appName)\n// to add or remove properties, edit the mapping file: '\(inputHintsFilePath)'.\n// README: https://github.com/theappbusiness/ConfigGenerator/blob/master/README.md\n\n"
let foundationImport = requiresFoundation ? "import Foundation\n\n" : ""
outputString = "\(headerComment)\(foundationImport)class \(outputClassName) {\n\(outputString)\n}\n"

do {
  try outputString.write(toFile: outputClassFileName, atomically: true, encoding: String.Encoding.utf8)
}
catch {
  fatalError("Failed to write to file at path \(outputClassFileName)")
}
