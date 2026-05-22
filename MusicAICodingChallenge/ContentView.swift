import SwiftUI

struct ContentView: View {
    @State private var navigator: Navigator

    init(repository: MusicRepositoryProtocol) {
        _navigator = State(initialValue: Navigator(repository: repository))
    }

    var body: some View {
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
        .environment(navigator)
        .preferredColorScheme(.dark)
    }
}
