import SwiftUI

enum Route: Hashable {
    case player(item: MusicItem, queue: [MusicItem])
    case album(collectionId: Int)
}

@MainActor
@Observable
final class Navigator {
    var path: [Route] = []

    let repository: MusicRepositoryProtocol
    let playerService: AudioPlayerService

    var playerViewModel: PlayerViewModel {
        PlayerViewModel(playerService: playerService)
    }

    init(repository: MusicRepositoryProtocol, playerService: AudioPlayerService) {
        self.repository = repository
        self.playerService = playerService
    }

    func navigateToPlayer(item: MusicItem, queue: [MusicItem]) {
        playerService.play(queue, startingAt: queue.firstIndex(of: item) ?? 0)
        path.append(.player(item: item, queue: queue))
    }

    func openPlayer() {
        guard let item = playerService.currentItem else { return }
        path.append(.player(item: item, queue: playerService.queue.items))
    }

    func navigateToAlbum(collectionId: Int) {
        path.append(.album(collectionId: collectionId))
    }
}
