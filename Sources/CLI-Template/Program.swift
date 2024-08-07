import ArgumentParser
import Foundation

public class Program: ParsableCommand, AsyncParsableCommand {
    enum CodingKeys: CodingKey {
        case program
    }

    var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "Program",
                             abstract: "Abstract about this App",
                             usage: nil,
                             discussion: "Discussion about this App",
                             version: "1.0",
                             shouldDisplay: false,
                             subcommands: [Program.self],
                             defaultSubcommand: nil,
                             helpNames: nil)
    }

    @Argument(help: "Root folder")
    var program: ProgramType = .type_a

    public required init() {}

    public func run() async throws {
        let executable: AsyncProgramExecutable?
        switch program {
        case .type_a:
            executable = AppOne()
        case .type_b:
            return
        }

        try await executable?.run()
    }
}
