import Foundation

struct DevConfig: ConfigProtocol {
  static let showDebugScreen: Bool = true
  static let apiBaseUrl: URL = URL(string: "http://api-mock.client.com/v1")!
}
