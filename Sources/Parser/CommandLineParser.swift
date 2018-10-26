//
//  CommandLineParser.swift
//  configen
//
//  Created by Suyash Srijan on 26/10/2018.
//  Copyright © 2018 The App Business. All rights reserved.
//

import Foundation
import CommandLineKit

/// This class is responsible for parsing the command line arguments
/// passed to the executable
class CommandLineParser {
  
  // MARK: - Properties -
  // MARK: Public
  
  /// The path to the Swift file to be used to generate the configuration Swift file
  let inputSwiftFilePath: String
  /// The name of the struct used in the generated configuration Swift file
  let outputStructName: String
  /// The path to the folder where the generated configuration Swift file will be stored
  let outputStructDirectory: String
  
  // MARK: - Init -
  // MARK: Public
  
  /// This method initializes the class, parses the command line arguments and sets the class parameters to the specified argument values.
  /// An error is thrown if the arguments are incorrect.
  init() {
    let flags = Flags()
    
    let _inputSwiftFilePath = flags.string("s", "swift-path", description: "Path to the input swift file.")
    let _outputStructName = flags.string("n", "struct-name", description: "The output config struct name")
    let _outputStructDirectory = flags.string("o", "output-directory", description: "The output config struct directory")
    
    if let error = flags.parsingFailure() {
      print(flags.usageDescription())
      fatalError(error)
    }
    
    self.inputSwiftFilePath = _inputSwiftFilePath.value!
    self.outputStructName = _outputStructName.value!
    self.outputStructDirectory = _outputStructDirectory.value!
  }
}
