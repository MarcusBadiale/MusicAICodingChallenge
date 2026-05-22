import SwiftUI

struct ContentView: View {
    @State private var navigator: Navigator

    init(repository: MusicRepositoryProtocol, playerService: AudioPlayerService) {
        _navigator = State(initialValue: Navigator(
            repository: repository,
            playerService: playerService
        ))
    }

    private var isOnPlayerScreen: Bool {
        navigator.path.contains { route in
            if case .player = route { return true }
            return false
        }
    }

    private var showMiniPlayer: Bool {
        navigator.playerService.currentItem != nil && !isOnPlayerScreen
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack(path: $navigator.path) {
                SongsView(repository: navigator.repository)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .player:
                            PlayerView(viewModel: navigator.playerViewModel)
                        case .album(let collectionId):
                            AlbumView(
                                collectionId: collectionId,
                                repository: navigator.repository
                            )
                        }
                    }
            }
            .contentMargins(.bottom, showMiniPlayer ? 70 : 0, for: .scrollContent)

            if showMiniPlayer {
                MiniPlayerView(playerService: navigator.playerService) {
                    navigator.openPlayer()
                }
                .animation(.smooth, value: showMiniPlayer)
            }
        }
        .environment(navigator)
        .preferredColorScheme(.dark)
    }
}
