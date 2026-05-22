import SwiftUI
import SwiftData

@main
struct MusicAICodingChallengeApp: App {
    let container: ModelContainer
    let repository: MusicRepositoryProtocol
    let playerService: AudioPlayerService

    init() {
        let container = try! ModelContainer(for: CachedSong.self)
        let store = MusicModelActor(modelContainer: container)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30
        sessionConfig.waitsForConnectivity = false
        let session = URLSession(configuration: sessionConfig)

        let networkClient: NetworkClientProtocol = NetworkClient(
            transport: session,
            decoder: decoder
        )

        let service: MusicServiceProtocol = ITunesService(client: networkClient)

        let repository: MusicRepositoryProtocol = MusicRepository(service: service, store: store)

        self.container = container
        self.repository = repository
        self.playerService = AudioPlayerService(repository: repository)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(repository: repository, playerService: playerService)
        }
    }
}
