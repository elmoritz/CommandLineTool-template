import Foundation

enum AppType {
    case adidasGlobal, adidasChina, confirmed, retail, appClip, fanaticsWidget
}

extension AppType {
    var projectId: Int {
        switch self {
        case .adidasGlobal,
             .adidasChina,
             .appClip,
             .fanaticsWidget:
            return 151_541
        case .confirmed:
            return 271_095
        case .retail:
            return 437_363
        }
    }

    var fallbackProjectId: Int? {
        switch self {
        case .adidasGlobal,
             .adidasChina,
             .appClip,
             .fanaticsWidget:
            return nil
        case .confirmed,
             .retail:
            return 151_541
        }
    }

    var tags: [String] {
        switch self {
        case .adidasGlobal,
             .adidasChina,
             .confirmed,
             .retail:
            return []
        case .appClip:
            return ["appclip_v2"]
        case .fanaticsWidget:
            return ["fanaticswidget"]
        }
    }

    var name: String {
        switch self {
        case .adidasGlobal:
            return "adidasGlobal"
        case .adidasChina:
            return "adidasChina"
        case .confirmed:
            return "confirmed"
        case .retail:
            return "retail"
        case .appClip:
            return "appClip"
        case .fanaticsWidget:
            return "fanaticsWidget"
        }
    }
}

extension AppType {
    private var relativeLocalizationPath: String {
        let pathToLocalizations: String
        switch self {
        case .adidasGlobal:
            pathToLocalizations = "Apps/adidas/Resources/Localization"
        case .adidasChina:
            pathToLocalizations = "Apps/adidasChina/Resources/Localization"
        case .confirmed:
            pathToLocalizations = "Apps/Confirmed/Resources/Localization"
        case .retail:
            pathToLocalizations = "Apps/Retail/Resources/Localization"
        case .appClip:
            pathToLocalizations = "Clips/adidasClip/Resources/Localization"
        case .fanaticsWidget:
            pathToLocalizations = "Extensions/adidasWidget/Resources/Localization"
        }
        return pathToLocalizations
    }

    func relativeLocalizationUrl() throws -> URL {
        let fileManager = Self.fileManager
        var pathComponent = Self.projectPath().components(separatedBy: Self.separator)
        let pathToLocalizations = relativeLocalizationPath.components(separatedBy: Self.separator)
        pathComponent.append(contentsOf: pathToLocalizations)

        let path = pathComponent.joined(separator: Self.separator)
        guard let url = URL(string: path) else { throw AppTypeError.pathInvalid }

        try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        var isDirectory: ObjCBool = true
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else { throw AppTypeError.pathDoesnExist }

        return url
    }
}

extension AppType {
    private var relativeSettingsPath: String? {
        let pathToSettings: String?
        switch self {
        case .adidasGlobal:
            pathToSettings = "Apps/adidas/Resources/Settings.bundle"
        case .adidasChina:
            pathToSettings = "Apps/adidasChina/Resources/Settings.bundle"
        case .confirmed:
            pathToSettings = "Apps/Confirmed/Resources/Settings.bundle"
        case .retail:
            pathToSettings = "Apps/Retail/Resources/Settings.bundle"
        case .appClip:
            pathToSettings = nil
        case .fanaticsWidget:
            pathToSettings = nil
        }
        return pathToSettings
    }

    func relativeSettingsUrl() throws -> URL? {
        let fileManager = Self.fileManager
        var pathComponent = Self.projectPath().components(separatedBy: Self.separator)
        guard let pathToLocalizations = relativeSettingsPath?.components(separatedBy: Self.separator) else { return nil }
        pathComponent.append(contentsOf: pathToLocalizations)

        let path = pathComponent.joined(separator: Self.separator)
        guard let url = URL(string: path) else { throw AppTypeError.pathInvalid }

        try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else { throw AppTypeError.pathDoesnExist }

        return url
    }
}

extension AppType {
    static var fileManager: FileManager = .default

    static let separator: String = "/"

    static func projectPath() -> String {
        let fileManager = self.fileManager
        var pathComponent = fileManager.currentDirectoryPath.components(separatedBy: separator)
        pathComponent.removeLast(2)
        return "\(separator)\(pathComponent.joined(separator: separator))"
    }

    static let CHINESE_LANGUAGE = "zh-Hans"
}

extension AppType {
    enum AppTypeError: Error {
        case pathInvalid
        case pathDoesnExist
    }
}
