//
//  FileTemplates.swift
//  configen
//
//  Created by Dónal O'Brien on 11/08/2016.
//  Copyright © 2016 The App Business. All rights reserved.
//

import Foundation

protocol Template {
  var variableNameToken: String { get }
  var customTypeToken: String { get }
  var bodyToken: String { get }
}

extension Template {
  var variableNameToken: String { return "$VARIABLE_NAME_TOKEN" }
  var customTypeToken: String { return "$CUSTOM_TYPE_TOKEN" }
  var bodyToken: String { return "$BODY_TOKEN" }
}

protocol HeaderTemplate: Template {

  var outputHeaderFileName: String { get }
  var headerImportStatements: String { get }
  var headerBody: String { get }

  var doubleDeclaration: String { get }
  var integerDeclaration: String { get }
  var stringDeclaration: String { get }
  var booleanDeclaration: String { get }
  var urlDeclaration: String { get }
  var customDeclaration: String { get }
}

protocol ImplementationTemplate: Template {

  var outputImplementationFileName: String { get }
  var implementationImportStatements: String { get }
  var implementationBody: String { get }

  var doubleImplementation: String { get }
  var integerImplementation: String { get }
  var stringImplementation: String { get }
  var booleanImplementation: String { get }
  var trueString: String { get }
  var falseString: String { get }
  var urlImplementation: String { get }
  var customImplementation: String { get }
  var valueToken: String { get }
}

extension ImplementationTemplate {
  var valueToken: String { return "$VALUE_TOKEN" }
}


struct ObjectiveCTemplate: HeaderTemplate, ImplementationTemplate {
  
  let optionsParser: OptionsParser
  
  //MARK: - HeaderTemplate
  
  var outputHeaderFileName: String { return "\(optionsParser.outputClassDirectory)/\(optionsParser.outputClassName).h" }
  
  var headerBody: String { return "@interface \(optionsParser.outputClassName) : NSObject \n\(bodyToken)\n@end\n" }
  
  var doubleDeclaration: String { return "+ (NSNumber *)\(variableNameToken)" }
  var integerDeclaration: String { return "+ (NSNumber *)\(variableNameToken)" }
  var stringDeclaration: String { return "+ (NSString *)\(variableNameToken)" }
  var booleanDeclaration: String { return "+ (BOOL)\(variableNameToken)" }
  var urlDeclaration: String { return "+ (NSURL *)\(variableNameToken)" }
  var customDeclaration: String { return "+ (\(customTypeToken))\(variableNameToken)" }
  var headerImportStatements: String { return "#import <Foundation/Foundation.h>\n\n" }
  
  //MARK: - ImplementationTemplate

  var outputImplementationFileName: String { return "\(optionsParser.outputClassDirectory)/\(optionsParser.outputClassName).m" }

  var implementationImportStatements: String { return "#import \"\(optionsParser.outputClassName).h\"" }
  
  var implementationBody: String { return "\n\n@implementation \(optionsParser.outputClassName) \n\(bodyToken)\n@end\n\n" }

  var integerImplementation: String { return integerDeclaration + "\n{\n  return @\(valueToken);\n}" }
  var doubleImplementation: String { return doubleDeclaration + "\n{\n  return @\(valueToken);\n}" }
  var stringImplementation: String { return stringDeclaration + "\n{\n  return @\"\(valueToken)\";\n}" }
  var booleanImplementation: String { return booleanDeclaration + "\n{\n  return \(valueToken);\n}" }
  var trueString: String { return "YES" }
  var falseString: String { return "NO" }
  var urlImplementation: String { return urlDeclaration + "\n{\n  return [NSURL URLWithString:@\"\(valueToken)\"];\n}" }
  var customImplementation: String { return customDeclaration + "\n{\n  return \(valueToken);\n}" }
}


struct SwiftTemplate: ImplementationTemplate {
  
  let optionsParser: OptionsParser
  
  //MARK: - ImplementationTemplate
    
  var implementationImportStatements: String { return "import Foundation" }
  
  var outputImplementationFileName: String { return "\(optionsParser.outputClassDirectory)/\(optionsParser.outputClassName).swift" }
  
  var implementationBody: String { return "\n\nclass \(optionsParser.outputClassName) {\n\(bodyToken)\n}\n\n" }

  var integerImplementation: String { return "  let \(variableNameToken): Int = \(valueToken)" }
  var doubleImplementation: String { return "  let \(variableNameToken): Double = \(valueToken)" }
  var stringImplementation: String { return "  let \(variableNameToken): String = \"\(valueToken)\"" }
  var booleanImplementation: String { return "  let \(variableNameToken): Bool = \(valueToken)" }
  
  var trueString: String { return "true" }
  var falseString: String { return "false" }
  
  var urlImplementation: String { return "  let \(variableNameToken): NSURL = NSURL(string: \"\(valueToken)\")!" }
  var customImplementation: String { return "  let \(variableNameToken): \(customTypeToken) = \(valueToken)" }
}



