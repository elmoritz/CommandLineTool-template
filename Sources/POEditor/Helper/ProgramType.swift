import ArgumentParser
import Foundation

enum ProgramType: String, ExpressibleByArgument, CaseIterable {
    case downloader
    case missing
    case ancient
    case whitelist

    init?(argument: String) {
        guard let programm = Self.makeProgramm(from: argument) else { return nil }
        self = programm
    }

    var description: String {
        switch self {
        case .downloader:
            return "STRINGS SYNC: Tool to download latest POEditor translations status and convert them into .strings files on the project"
        case .missing:
            return "MISSING CHECKER: Script that checks the whole project finding keys that have no translation in POEditor"
        case .ancient:
            return "MISSING CHECKER: Script that checks the whole project finding keys that have no translation in POEditor"
        case .whitelist:
            return "STRINGS WHITELIST: Script that creates/updates strings-whitelist-[app].txt file with the POEditor keys containing incorrect arguments or missing them by purpose. The keys added to the whitelist are allowed to bypass the check for inconsistent translations' arguments and they are not displayed in the download-strings.py output. IMPORTANT: comment describing the reason why the key is whitelisted is mandatory."
        }
    }

    static func makeProgramm(from string: String) -> ProgramType? {
        let allProgramm = ProgramType.allCases
        for program in allProgramm {
            if string.lowercased() == program.rawValue.lowercased() {
                return program
            }
        }
        return nil
    }
}

extension ProgramType: Codable {}
