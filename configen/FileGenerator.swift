//
//  FileGenerator.swift
//  configen
//
//  Created by Dónal O'Brien on 11/08/2016.
//  Copyright © 2016 The App Business. All rights reserved.
//

import Foundation

struct FileGenerator {
  
  let optionsParser: OptionsParser
  
  func generateHeaderFile(withTemplate template: HeaderTemplate) {
    
    var headerBodyContent = ""
    for (variableName, type) in optionsParser.hintsDictionary() {
      let headerLine = methodDeclarationForVariableName(variableName, type: type, template: template)
      headerBodyContent.appendContentsOf("\n" + headerLine + ";" + "\n")
    }
    
    var headerBody = template.headerBody
    headerBody.replace(template.bodyToken, withString: headerBodyContent)
    
    do {
      let headerOutputString = template.autoGenerationComment + template.headerImportStatements + headerBody
      try headerOutputString.writeToFile(template.outputHeaderFileName, atomically: true, encoding: NSUTF8StringEncoding)
    }
    catch {
      fatalError("Failed to write to file at path \(template.outputHeaderFileName)")
    }
    
  }
  
  
  func generateImplementationFile(withTemplate template: ImplementationTemplate) {
    var implementationBodyContent = ""
    for (variableName, type) in optionsParser.hintsDictionary() {
      let implementationLine = methodImplementationForVariableName(variableName, type: type, plistDictionary: optionsParser.plistDictionary(), template: template)
      implementationBodyContent.appendContentsOf("\n" + implementationLine + "\n")
    }
    
    var implementationBody = template.implementationBody
    implementationBody.replace(template.bodyToken, withString: implementationBodyContent)
    
    do {
      let implementationOutputString = template.autoGenerationComment + template.implementationImportStatements + implementationBody
      try implementationOutputString.writeToFile(template.outputImplementationFileName, atomically: true, encoding: NSUTF8StringEncoding)
    }
    catch {
      fatalError("Failed to write to file at path \(template.outputImplementationFileName)")
    }
    
  }
  
  
  func methodDeclarationForVariableName(variableName: String, type: String, template: HeaderTemplate) -> String {
    var line = ""
    
    switch (type) {
    case ("Double"):
      line += template.doubleDeclaration
      
    case ("Int"):
      line += template.integerDeclaration
      
    case ("String"):
      line += template.stringDeclaration
      
    case ("Bool"):
      line += template.booleanDeclaration
      
    case ("NSURL"):
      line += template.urlDeclaration
      
    default:
      fatalError("Unknown type: \(type)")
    }
    
    line.replace(template.variableNameToken, withString: variableName)
    
    return line
  }
  
  
  func methodImplementationForVariableName(variableName: String, type: String, plistDictionary: [String:AnyObject], template: ImplementationTemplate) -> String {
    
    guard let value = plistDictionary[variableName] else {
      fatalError("No configuration setting for variable name: \(variableName)")
    }
    
    var line = ""
    
    switch (type) {
    case ("Double"):
      line += template.doubleImplementation
      
    case ("Int"):
      line += template.integerImplementation
      
    case ("String"):
      line += template.stringImplementation
      
    case ("Bool"):
      let boolString = value as! Bool ? template.trueString : template.falseString
      line += template.booleanImplementation
      line.replace(template.valueToken, withString: boolString)
      
    case ("NSURL"):
      let url = NSURL(string: "\(value)")!
      guard url.host != nil else {
        fatalError("Found URL without host: \(url) for setting: \(variableName)")
      }
      line += template.urlImplementation
      
    default:
      fatalError("Unknown type: \(type)")
    }
    
    line.replace(template.variableNameToken, withString: variableName)
    line.replace(template.valueToken, withString: "\(value)")
    
    return line
  }
  
}

extension String {
  mutating func replace(token: String, withString string: String) {
    self = stringByReplacingOccurrencesOfString(token, withString: string)
  }
  
  var trimmed: String {
    return (self as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  }
}
