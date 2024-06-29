import Foundation

protocol POEditorConnection {
    func fetchAvailableLanguages(for appType: AppType) async throws -> [LanguageResponse.Result.Language]
    func fetchTranslations(for appType: AppType, in language: String) async throws -> [TermsResponse.TermResult.Term]
}

class POEditorConnectionImpl {
    private static let httpMethodPost: String = "POST"
    private static let httpMethodGet: String = "GET"

    enum POEditorConnectionError: LocalizedError {
        case missingTranslation(String)
        case missingPermission(AppType)

        var errorDescription: String? {
            switch self {
            case let .missingTranslation(errorMessage):
                return errorMessage
            case let .missingPermission(app):
                return "You are missing permissions for \(app.name).app"
            }
        }
    }

    enum RequestType {
        case availableLanguages, terms
    }

    let urlSession: URLSession = .init(configuration: URLSessionConfiguration.default)
    let accessToken: String

    init(with accessToken: String) {
        self.accessToken = accessToken
    }

    private func convert<C: Codable>(_ codableObject: C) -> Data? {
        do {
            let decoder = JSONEncoder()
            return try decoder.encode(codableObject)
        } catch {
            return nil
        }
    }

    private func makeUrl(type requestType: RequestType) -> URL {
        var urlString = "https://api.poeditor.com/v2"
        switch requestType {
        case .availableLanguages:
            urlString.append("/languages/available")
        case .terms:
            urlString.append("/terms/list")
        }
        return URL(string: urlString)! // swiftlint:disable:this force_unwrapping
    }

    private func makeRequest(type requestType: RequestType, for _: AppType, body: Data?) -> URLRequest {
        let url = makeUrl(type: requestType)
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = Self.httpMethodPost
        request.httpBody = body

        return request
    }

    private func execute<T: Decodable>(request: URLRequest) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            urlSession.dataTask(
                with: request,
                completionHandler: { data, _, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    } else if let data {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        do {
                            let object: T = try decoder.decode(T.self, from: data)
                            continuation.resume(returning: object)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                }
            ).resume()
        }
    }
}

private extension POEditorConnectionImpl {
    struct BodyTermsList: Codable {
        let apiToken: String
        let id: Int
        let language: String

        private enum CodingKeys: String, CodingKey {
            case apiToken = "api_token"
            case id, language
        }

        func toData() -> Data? {
            return "api_token=\(apiToken)&id=\(String(id))&language=\(language)".data(using: .utf8)
        }
    }

    struct BodyLanguageAvailable: Codable {
        let apiToken: String
        let id: Int

        private enum CodingKeys: String, CodingKey {
            case apiToken = "api_token"
            case id
        }

        func toData() -> Data? {
            return "api_token=\(apiToken)&id=\(String(id))".data(using: .utf8)
        }
    }
}

extension POEditorConnectionImpl: POEditorConnection {
    func fetchTranslations(for appType: AppType, in language: String) async throws -> [TermsResponse.TermResult.Term] {
        do {
            guard let body = "api_token=\(accessToken)&id=\(String(appType.projectId))&language=\(language)".data(using: .utf8) else { return [] }

            let request = makeRequest(type: .terms, for: appType, body: body)
            let response: TermsResponse = try await execute(request: request)
            guard let result = response.result else {
                if response.response.code == "403" {
                    throw POEditorConnectionError.missingPermission(appType)
                }
                throw POEditorConnectionError.missingTranslation(language)
            }
            return result.terms
        } catch {
            guard let poEditorError = error as? POEditorConnectionError else {
                print(error)
                throw error
            }
            throw poEditorError
        }
    }

    func fetchAvailableLanguages(for appType: AppType) async throws -> [LanguageResponse.Result.Language] {
        guard let body = "api_token=\(accessToken)&id=\(String(appType.projectId))".data(using: .utf8) else { return [] }
        let request = makeRequest(type: .availableLanguages, for: appType, body: body)
        let response: LanguageResponse = try await execute(request: request)
        return response.result?.languages ?? []
    }
}
