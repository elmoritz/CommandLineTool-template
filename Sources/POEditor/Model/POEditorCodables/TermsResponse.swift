import Foundation

// MARK: - TermsResponse

struct TermsResponse: Codable {
    let response: TermResponse
    let result: TermResult?

    // MARK: - Response

    struct TermResponse: Codable {
        let status, code, message: String
    }

    // MARK: - TermResult

    struct TermResult: Codable {
        let terms: [Term]

        // MARK: - Term

        struct Term: Codable {
            private let term: String
            let created: Date
            // might be used in the future
            // let updated: Date?
            private let translation: Translation
            // no idea what this might be used for. see enum Reference
            // let reference: Reference

            // might be used in the future
            // let tags: [String]

            // useless for now
            // let comment: String

            // enum Reference: String, Codable {
            //    case checkout = "checkout"
            //    case csCZ = "cs_CZ"
            //    case devKey = "[DEV] Key"
            //    case empty = ""
            // }

            var hasPlurals: Bool {
                switch translation.content {
                case .plurals:
                    return true
                default:
                    return false
                }
            }

            var singleValue: String? {
                translation.content.single
            }

            var singleKey: String {
                term
            }

            var oneValue: String? {
                translation.content.one
            }

            var oneKey: String {
                "\(term)#one"
            }

            var fewValue: String? {
                translation.content.few
            }

            var fewKey: String {
                "\(term)#few"
            }

            var manyValue: String? {
                translation.content.many
            }

            var manyKey: String {
                "\(term)#many"
            }

            var otherValue: String? {
                translation.content.other
            }

            var otherKey: String {
                "\(term)#many"
            }

            // MARK: - Translation

            struct Translation: Codable {
                let content: Translations
                let fuzzy: Int
                let updated: String

                enum Translations: Codable {
                    case plurals(Plurals)
                    case single(String)

                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        if let text = try? container.decode(String.self) {
                            self = .single(text)
                            return
                        }
                        if let content = try? container.decode(Plurals.self) {
                            self = .plurals(content)
                            return
                        }
                        throw DecodingError.typeMismatch(Translations.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Translations"))
                    }

                    func encode(to encoder: Encoder) throws {
                        var container = encoder.singleValueContainer()
                        switch self {
                        case let .plurals(x):
                            try container.encode(x)
                        case let .single(x):
                            try container.encode(x)
                        }
                    }

                    var single: String? {
                        switch self {
                        case let .single(text) where !text.isEmpty:
                            return text
                        default:
                            return nil
                        }
                    }

                    var one: String? {
                        switch self {
                        case let .plurals(content):
                            return content.one
                        default:
                            return nil
                        }
                    }

                    var few: String? {
                        switch self {
                        case let .plurals(content):
                            return content.few
                        default:
                            return nil
                        }
                    }

                    var many: String? {
                        switch self {
                        case let .plurals(content):
                            return content.many
                        default:
                            return nil
                        }
                    }

                    var other: String? {
                        switch self {
                        case let .plurals(content):
                            return content.other
                        default:
                            return nil
                        }
                    }

                    // MARK: - ContentClass

                    struct Plurals: Codable {
                        private let oneValue, fewValue, manyValue, otherValue: String?

                        private enum CodingKeys: String, CodingKey {
                            case oneValue = "one"
                            case fewValue = "few"
                            case manyValue = "many"
                            case otherValue = "other"
                        }

                        var one: String? {
                            oneValue.isNilOrEmpty() ? nil : oneValue
                        }

                        var few: String? {
                            fewValue.isNilOrEmpty() ? nil : fewValue
                        }

                        var many: String? {
                            manyValue.isNilOrEmpty() ? nil : manyValue
                        }

                        var other: String? {
                            otherValue.isNilOrEmpty() ? nil : otherValue
                        }
                    }
                }
            }
        }
    }
}

private extension String? {
    func isNilOrEmpty() -> Bool {
        guard let self else { return true }
        return self.isEmpty
    }
}
