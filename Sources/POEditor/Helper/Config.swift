import Foundation

enum Config {
    static let apiAccessToken: String? = ProcessInfo.processInfo.environment["POEDITOR_USER_API_KEY"]
}
