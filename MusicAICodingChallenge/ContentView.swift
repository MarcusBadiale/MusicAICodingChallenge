import SwiftUI

enum Route: Hashable {
    case player(item: MusicItem, queue: [MusicItem])
    case album(collectionId: Int)
}

struct ContentView: View {
    let repository: MusicRepositoryProtocol
    @State private var path: [Route] = []
    @State private var songsViewModel: SongsViewModel?
    @State private var playerViewModel = PlayerViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let songsViewModel {
                    SongsView(viewModel: songsViewModel) { item, queue in
                        playerViewModel.load(item: item, queue: queue)
                        Task { try? await repository.recordPlay(item: item) }
                        path.append(.player(item: item, queue: queue))
                    } onViewAlbum: { collectionId in
                        path.append(.album(collectionId: collectionId))
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .player:
                    PlayerView(viewModel: playerViewModel) { collectionId in
                        path.append(.album(collectionId: collectionId))
                    }
                case .album(let collectionId):
                    AlbumView(
                        viewModel: AlbumViewModel(
                            collectionId: collectionId,
                            repository: repository
                        )
                    ) { item, queue in
                        playerViewModel.load(item: item, queue: queue)
                        Task { try? await repository.recordPlay(item: item) }
                        path.append(.player(item: item, queue: queue))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if songsViewModel == nil {
                songsViewModel = SongsViewModel(repository: repository)
            }
        }
    }
}
