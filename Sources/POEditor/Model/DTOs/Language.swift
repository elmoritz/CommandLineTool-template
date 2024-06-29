import Foundation

enum Language {
    struct Xcode {
        let languageCode: String

        init(languageCode: String) {
            self.languageCode = languageCode
        }

        init(with folderName: String) {
            let extractedLanguage = folderName.lowercased().replacingOccurrences(of: ".lproj", with: "")
            if extractedLanguage.lowercased() == "zh-hans" {
                languageCode = "zh-CN"
            } else {
                languageCode = extractedLanguage
            }
        }

        var languageAcronym: String {
            (components.first ?? "").lowercased()
        }

        var countryAcronym: String? {
            components.last?.uppercased()
        }

        private var components: [String] {
            languageCode.components(separatedBy: CharacterSet(arrayLiteral: "-"))
        }
    }

    struct POEditor {
        let languageCode: String

        var languageAcronym: String {
            (components.first ?? "").lowercased()
        }

        var countryAcronym: String? {
            components.last
        }

        private var components: [String] {
            languageCode.components(separatedBy: CharacterSet(arrayLiteral: "-"))
        }
    }

    static func convert(_ xcode: Language.Xcode) -> Language.POEditor {
        .init(languageCode: xcode.languageCode.replacingOccurrences(of: "_", with: "-"))
    }

    static func convert(_ poeditor: Language.POEditor) -> Language.Xcode {
        .init(languageCode: poeditor.languageCode.replacingOccurrences(of: "-", with: "_"))
    }
}
