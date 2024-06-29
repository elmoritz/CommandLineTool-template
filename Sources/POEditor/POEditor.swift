import ArgumentParser
import Foundation

public class POEditor: ParsableCommand, AsyncParsableCommand {
    enum CodingKeys: CodingKey {
        case program
    }

    var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "poeditor",
                             abstract: "Abstract about this App",
                             usage: nil,
                             discussion: "Discussion about this App",
                             version: "1.0",
                             shouldDisplay: false,
                             subcommands: [POEditor.self],
                             defaultSubcommand: nil,
                             helpNames: nil)
    }

    @Argument(help: "Root folder")
    var program: ProgramType = .downloader

    var connection: POEditorConnection {
        guard let apiAccessToken = Config.apiAccessToken else {
            fatalError("POEDITOR_USER_API_KEY is not set correctly")
        }
        return POEditorConnectionImpl(with: apiAccessToken)
    }

    var accessToken: String?

    public required init() {
        guard let apiAccessToken = Config.apiAccessToken else {
            fatalError("POEDITOR_USER_API_KEY is not set correctly")
        }
        accessToken = apiAccessToken
    }

    public func run() async throws {
        let executable: ExecutableProgram?
        switch program {
        case .downloader:
            executable = Downloader(connectionManager: connection, appType: .adidasGlobal)
        case .missing:
            return
        case .ancient:
            return
        case .whitelist:
            return
        }

        try await executable?.run()
    }
}
