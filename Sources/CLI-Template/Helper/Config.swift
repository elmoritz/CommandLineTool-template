import Foundation

enum Config {
    static let apiAccessToken: String? = ProcessInfo.processInfo.environment["ENVIRONMENT_VARIABLE"]
}
