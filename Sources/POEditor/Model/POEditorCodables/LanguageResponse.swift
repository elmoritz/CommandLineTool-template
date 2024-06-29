import Foundation

// MARK: - Welcome

struct LanguageResponse: Codable {
    let response: Response
    let result: Result?

    // MARK: - Response

    struct Response: Codable {
        let status, code, message: String
    }

    // MARK: - Result

    struct Result: Codable {
        let languages: [Language]

        // MARK: - Language

        struct Language: Codable {
            let name, code: String
        }
    }
}
