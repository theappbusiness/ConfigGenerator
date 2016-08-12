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
  
  init?(arguments: [String]) {
    guard arguments.count == 5 || arguments.count == 6 else {
      return nil
    }
    
    let isObjcValue = arguments.count == 6 && arguments.last == "objc"
    if arguments.count == 6 {
      guard isObjcValue else { return nil }
    }
    
    appName = (arguments.first! as NSString).lastPathComponent
    inputPlistFilePath = arguments[1]
    inputHintsFilePath = arguments[2]
    outputClassName = arguments[3]
    outputClassDirectory = arguments[4]
    isObjC = isObjcValue
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

