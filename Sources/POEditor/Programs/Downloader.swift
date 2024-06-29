import Foundation

struct Downloader: ExecutableProgram {
    enum DownloaderError: Error {
        case somethingWentWrong
    }

    let connectionManager: POEditorConnection
    let appType: AppType

    init(connectionManager: POEditorConnection, appType: AppType) {
        self.connectionManager = connectionManager
        self.appType = appType
    }

    func run() async throws {
        let installedLanguages = try getCreatedLanguagesInProject()
        var available: Set<String> = []
        var unavailable: Set<String> = []
        var languageDTOs: [TranslationDTO] = []
        for language in installedLanguages {
            let languageCode = language.languageCode
            do {
                let translations = try await connectionManager.fetchTranslations(for: appType, in: languageCode)
                // TODO: move this to a new thread
                let object = Translation(with: languageCode)
                object.add(translations: translations)
                let dto = object.toDto()
                languageDTOs.append(dto)
                available.insert(languageCode)
            } catch {
                if let poEditorError = error as? POEditorConnectionImpl.POEditorConnectionError {
                    switch poEditorError {
                    case .missingTranslation:
                        unavailable.insert(languageCode)
                    case .missingPermission:
                        print(poEditorError.localizedDescription)
                        exit(1)
                    }
                }
            }
        }

        if !unavailable.isEmpty {
            print("The following langauges could not be downloaded")
            print(unavailable.joined(separator: "\n"))
            exit(1)
        }
    }

    private func getCreatedLanguagesInProject() throws -> [Language.Xcode] {
        let relativeLocalizationUrl = try appType.relativeLocalizationUrl()
        return try FileManager.default
            .contentsOfDirectory(atPath: relativeLocalizationUrl.absoluteString)
            .map { Language.Xcode(with: $0) }
    }
}
