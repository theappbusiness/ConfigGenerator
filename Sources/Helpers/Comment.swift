//
//  Comment.swift
//  SwiftSyntax
//
//  Created by Suyash Srijan on 26/10/2018.
//  Copyright © 2018 The App Business. All rights reserved.
//

import Foundation
import SwiftSyntax

/// This class is responsible for constructing an auto-generated comment header
/// which will be placed at the top of the file
class Comment {
  
  // MARK: - Properties -
  // MARK: Private
  
  /// The name of the app
  private let name: String
  
  /// The auto-generated comment text token
  ///
  /// This is a hardcoded token because SwiftSyntax does not support constructing
  /// a block comment token
  private lazy var autoGenCommentTextToken = SyntaxFactory.makeUnknown("""
    /* Auto-generated by \(name)\n\n To add or remove properties, edit the protocol and update struct conformance.\n README: https://github.com/theappbusiness/ConfigGenerator/blob/master/README.md\n*/\n
    """, trailingTrivia: .newlines(1))
  
  // MARK: - Init -
  // MARK: Public
  
  /// Class initializer
  ///
  /// - Parameter appName: The name of the app
  init(appName: String) {
    self.name = appName
  }
  
  // MARK: - Functions -
  // MARK: Public
  
  /// Create and return a `CodeBlockItemSyntax` containing the
  /// auto-generated comment text token
  ///
  /// - Returns: A `CodeBlockItemSyntax` containing the auto-generated
  ///            comment text token
  func autoGeneratedComment() -> CodeBlockItemSyntax {
    return CodeBlockItemSyntax { builder in
      builder.useItem(autoGenCommentTextToken)
    }
  }
}
