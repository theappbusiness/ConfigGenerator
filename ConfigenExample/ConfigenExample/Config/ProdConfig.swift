import Foundation

struct ProdConfig: ConfigProtocol {
  static let showDebugScreen: Bool = false
  static let apiBaseUrl: URL = URL(string: "https://api.client.com/v1")!
}
