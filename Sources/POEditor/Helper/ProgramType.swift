import Foundation
import ArgumentParser

enum ProgramType: String, ExpressibleByArgument, CaseIterable {
    case type_a
    case type_b

    init?(argument: String) {
        guard let programm = Self.makeProgramm(from: argument) else { return nil }
        self = programm
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

extension ProgramType: Codable { }
