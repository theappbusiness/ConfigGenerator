//
//  main.swift
//  configen
//
//  Created by Sam Dods on 29/09/2015.
//  Copyright © 2015 The App Business. All rights reserved.
//

import Foundation
import ArgumentParser

struct Configen: ParsableCommand {

    static let configuration = CommandConfiguration(helpNames: .long)

    @Option(name: .shortAndLong, help: "Path to the input plist file")
    var plistPath: String = ""

    @Option(name: .shortAndLong, help: "Path to the input hints file")
    var hintsPath: String = ""

    @Option(name: [.customShort("n"), .long], help: "The output config class name")
    var className: String = ""

    @Option(name: .shortAndLong, help: "The output config class directory")
    var outputDirectory: String = ""

    @Flag(name: [.customShort("c"), .customLong("objective-c")], help: "Whether to generate Objective-C files instead of Swift. Default value of false")
    var isObjC: Bool = false

    func run() throws {
        let appName = (CommandLine.arguments.first! as NSString).lastPathComponent
        let options = Options(appName: appName, inputPlistFilePath: plistPath, inputHintsFilePath: hintsPath, outputClassName: className, outputClassDirectory: outputDirectory)
        let fileGenerator = FileGenerator(options: options)
        if isObjC {
          let template = ObjectiveCTemplate(options: options)
          try fileGenerator.generateHeaderFile(withTemplate: template)
          try fileGenerator.generateImplementationFile(withTemplate: template)
        } else {
          let template = SwiftTemplate(options: options)
          try fileGenerator.generateImplementationFile(withTemplate: template)
        }
    }
}

Configen.main()
