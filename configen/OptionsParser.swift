//
//  OptionsParser.swift
//  configen
//
//  Created by Dónal O'Brien on 10/08/2016.
//  Copyright © 2016 The App Business. All rights reserved.
//

import Foundation

class OptionsParser {

  let appName: String
  let inputPlistFilePath: String
  let inputHintsFilePath: String
  let outputClassName: String
  let outputClassDirectory: String
  let isObjC: Bool
  
  init(appName: String) {
    let cli = CommandLine()
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
  
  lazy var plistDictionary: Dictionary<String, AnyObject> = { [unowned self] in
    
    guard let data = NSData(contentsOfFile: self.inputPlistFilePath) else {
      fatalError("No data at path: \(self.inputPlistFilePath)")
    }
    
    guard let plistDictionary = (try? NSPropertyListSerialization.propertyListWithData(data, options: .Immutable, format: nil)) as? Dictionary<String, AnyObject> else {
      fatalError("Failed to create plist")
    }
    
    return plistDictionary
  }()
  
  lazy var hintsDictionary: Dictionary<String, String> = { [unowned self] in
    guard let hintsString = try? NSString(contentsOfFile: self.inputHintsFilePath, encoding: NSUTF8StringEncoding) else {
      fatalError("No data at path: \(self.inputHintsFilePath)")
    }
    
    var hintsDictionary = Dictionary<String, String>()
    
    let hintLines = hintsString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    for hintLine in hintLines where hintLine.trimmed.characters.count > 0 {
      let hints = hintLine.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ":")).map { $0.trimmed }
      guard hints.count == 2 else {
        fatalError("Expected \"variableName : Type\", instead of \"\(hintLine)\"")
      }
      let (variableName, type) = (hints[0], hints[1])
      hintsDictionary[variableName] = type
    }
    
    return hintsDictionary
  }()
}

