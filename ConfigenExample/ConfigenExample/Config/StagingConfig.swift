import Foundation

struct StagingConfig: ConfigProtocol {
  static let showDebugScreen: Bool = true
  static let apiBaseUrl: URL = URL(string: "https://api-staging.client.com/v1")!
}
