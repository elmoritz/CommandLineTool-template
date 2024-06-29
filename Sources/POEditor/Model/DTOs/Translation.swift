import Foundation
import RegexBuilder

struct TranslationDTO {
    let languageCode: String
    let infoPlistEntries: [String: String]
    let settingsBundle: [String: String]
    let regularTranslations: [String: String]
}

class Translation {
    private let languageCode: String
    private var infoPlistEntries: [String: String] = [:]
    private var settingsBundle: [String: String] = [:]
    private var regularTranslations: [String: String] = [:]

    init(with language: String) {
        languageCode = language
    }

    func add(translations: [TermsResponse.TermResult.Term]) {
        let infoPlistTranslations = translations.filter { Self.INFO_PLIST_MAPPING.contains($0.singleKey) }

        infoPlistTranslations.forEach { term in
            if let singleValue = term.singleValue {
                infoPlistEntries[term.singleKey] = Self.encodeTranlsation(singleValue)
            }
        }

        let settingsTranslations = translations.filter { Self.SETTINGS_ROOT_MAPPING.contains($0.singleKey) }

        settingsTranslations.forEach { term in
            if let singleValue = term.singleValue {
                settingsBundle[term.singleKey] = Self.encodeTranlsation(singleValue)
            }
        }

        let appTranslations = translations.filter { !Self.SETTINGS_ROOT_MAPPING.contains($0.singleKey) && !Self.INFO_PLIST_MAPPING.contains($0.singleKey) }

        appTranslations.forEach { term in
            if term.hasPlurals {
                if let oneValue = term.oneValue {
                    regularTranslations[term.oneKey] = Self.encodeTranlsation(oneValue)
                }
                if let fewValue = term.fewValue {
                    regularTranslations[term.fewKey] = Self.encodeTranlsation(fewValue)
                }
                if let manyValue = term.manyValue {
                    regularTranslations[term.manyKey] = Self.encodeTranlsation(manyValue)
                }
                if let otherValue = term.otherValue {
                    regularTranslations[term.otherKey] = Self.encodeTranlsation(otherValue)
                }
            } else {
                if let singleValue = term.singleValue {
                    regularTranslations[term.singleKey] = Self.encodeTranlsation(singleValue)
                }
            }
        }
    }

    func toDto() -> TranslationDTO {
        TranslationDTO(languageCode: languageCode,
                       infoPlistEntries: infoPlistEntries,
                       settingsBundle: settingsBundle,
                       regularTranslations: regularTranslations)
    }
}

extension Translation {
    // Keys used specifically in the InfoPlist.strings file
    private static let INFO_PLIST_MAPPING = [
        "NSCameraUsageDescription",
        "NSLocationAlwaysAndWhenInUseUsageDescription",
        "NSLocationWhenInUseUsageDescription",
        "NSPhotoLibraryUsageDescription",
        "NFCReaderUsageDescription",
        "NSMicrophoneUsageDescription",
        "NSBluetoothPeripheralUsageDescription",
        "NSPhotoLibraryAddUsageDescription",
        "NSCalendarsUsageDescription",
        "NSBluetoothAlwaysUsageDescription",
        "NSUserTrackingUsageDescription",
        "LocationTemporaryUsageDescriptionUnbx",
        "LocationTemporaryUsageDescription",
        "NSContactsUsageDescription",
        "NSUserTrackingUsageDescription",
        "homescreen_shortcut_search",
        "homescreen_shortcut_new",
        "homescreen_shortcut_account",
        "homescreen_shortcut_store_finder",
        "homescreen_shortcut_order_status",
        "homescreen_shortcut_wishlist",
        "homescreen_shortcut_basket",
        "homescreen_shortcut_creators_pass",
        "RetailEventPreciseLocationReason",
    ]

    // Keys used specifically in the Root.strings file for the Settings Bundle
    private static let SETTINGS_ROOT_MAPPING = [
        "bundle_autoplay_videos_title",
        "bundle_autoplay_videos_footer",
        "bundle_acknowledgements",
    ]

    private static func encodeTranlsation(_ original: String) -> String {
        var encoded = original.replacingOccurrences(of: "\\n", with: "\n")
        // logic to replace 's' in the end of format with '@' (left to right language)
        encoded.replace(#"%((\d\$)?)s"#, with: #"%\1@"#)
        // this caught my attention, it is not included in the original python script, but
        // from the translation I looks like some one also reversed the format
//        encoded.replace(#"s((\d\$)?)%"#, with: #"@\1%"#)
        return encoded
    }
}

private extension String {
    mutating func replace(_ pattern: String, with substitutionString: String) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }

        let stringRange = NSRange(location: 0, length: utf16.count)
        let lookupRange = (self as NSString).range(of: pattern, options: .regularExpression, range: stringRange)
        if lookupRange.intersection(stringRange) != nil {
            self = regex.stringByReplacingMatches(in: self, range: lookupRange, withTemplate: substitutionString)
        }
    }
}
