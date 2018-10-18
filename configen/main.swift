//
//  main.swift
//  configen
//
//  Created by Sam Dods on 29/09/2015.
//  Copyright © 2015 The App Business. All rights reserved.
//

import Foundation

let appName = (CommandLine.arguments.first! as NSString).lastPathComponent
let parser = OptionsParser(appName: appName)
let fileGenerator = FileGenerator(optionsParser: parser)

if parser.isObjC {
  let template = ObjectiveCTemplate(optionsParser: parser)
  fileGenerator.generateHeaderFile(withTemplate: template)
  fileGenerator.generateImplementationFile(withTemplate: template)
} else {
  let template = SwiftTemplate(optionsParser: parser)
  fileGenerator.generateImplementationFile(withTemplate: template)
}
