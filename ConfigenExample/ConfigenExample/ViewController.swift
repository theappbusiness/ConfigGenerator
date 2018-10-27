//
//  ViewController.swift
//  ConfigenExample
//
//  Created by Suyash Srijan on 27/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet private var textLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textLabel.text = """
    Should the debug screen be displayed: \(AppConfig.showDebugScreen)\n\nThe base URL for making API calls is: \(AppConfig.apiBaseUrl)
    """
  }
}

