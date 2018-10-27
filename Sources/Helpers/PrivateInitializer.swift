//
//  PrivateInitializer.swift
//  CommandLineKit
//
//  Created by Suyash Srijan on 27/10/2018.
//

import Foundation
import SwiftSyntax

/// This class is responsible for creating a private initializer declaration syntax, which
/// will be inserted into the output struct
class PrivateInitializer {
  
  // MARK: - Properties -
  // MARK: Private
  
  /// A token representing the private keyword
  private lazy var privateToken = SyntaxFactory.makeBlankDeclModifier().withName(SyntaxFactory.makePrivateKeyword(leadingTrivia: [.newlines(1), .tabs(1)], trailingTrivia: .spaces(1)))
  
  /// A token representing the init keyword
  private lazy var initToken = SyntaxFactory.makeInitKeyword()
  
  /// A token representing an empty param list & body.
  ///
  /// For some reason, constructing one from scratch doesn't work, hence why
  /// this is hardcoded by using a token with hardcoded text.
  private lazy var emptyParamsBodyToken = SyntaxFactory.makeUnknown("() {}")
  
  // MARK: - Functions -
  // MARK: Public
  
  /// Create a private initializer declaration with an empty parameter list
  /// and body
  ///
  /// - Returns: A `InitializerDeclSyntax` representing a private initializer with
  ///            no parameters and an empty body
  func privateInitializerDeclWithEmptyBody() -> InitializerDeclSyntax {
    return InitializerDeclSyntax { builder in
      builder.addModifier(privateToken)
      builder.useInitKeyword(initToken)
      builder.useBody(buildEmptyCodeBlockSyntax())
    }
  }
  
  // MARK: Private
  
  /// Create an empty parameter list and body code block
  ///
  /// - Returns: A `CodeBlockItemSyntax` representing an empty parameter list
  ///            and body
  private func buildEmptyParamsBodySyntax() -> CodeBlockItemSyntax {
    return CodeBlockItemSyntax { builder in
      builder.useItem(emptyParamsBodyToken)
    }
  }
  
  /// Create an empty code block
  ///
  /// - Returns: A `CodeBlockSyntax` representing a code block with no body
  private func buildEmptyCodeBlockSyntax() -> CodeBlockSyntax {
    return CodeBlockSyntax { builder in
      builder.addCodeBlockItem(buildEmptyParamsBodySyntax())
    }
  }
}
