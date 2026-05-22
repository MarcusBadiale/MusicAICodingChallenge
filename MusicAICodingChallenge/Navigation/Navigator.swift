import SwiftUI

enum Route: Hashable {
    case player(item: MusicItem, queue: [MusicItem])
    case album(collectionId: Int)
}

@Observable
final class Navigator {
    var path: [Route] = []

    let repository: MusicRepositoryProtocol
    let playerViewModel = PlayerViewModel()

    init(repository: MusicRepositoryProtocol) {
        self.repository = repository
    }

    func navigateToPlayer(item: MusicItem, queue: [MusicItem]) {
        playerViewModel.load(item: item, queue: queue)
        Task { try? await repository.recordPlay(item: item) }
        path.append(.player(item: item, queue: queue))
    }

    func navigateToAlbum(collectionId: Int) {
        path.append(.album(collectionId: collectionId))
    }
}
