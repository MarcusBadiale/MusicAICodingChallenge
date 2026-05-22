import Foundation

@MainActor
@Observable
final class AlbumViewModel {
    private(set) var tracks: [MusicItem] = []
    private(set) var state: ViewState = .idle

    let collectionId: Int

    private let repository: MusicRepositoryProtocol

    init(collectionId: Int, repository: MusicRepositoryProtocol) {
        self.collectionId = collectionId
        self.repository = repository
    }

    func onAppear() async {
        guard state == .idle else { return }
        state = .loading
        do {
            let items = try await repository.getAlbum(collectionId: collectionId)
            tracks = items
            state = items.isEmpty ? .error(.empty) : .loaded
        } catch let error as MusicError {
            state = .error(error)
        } catch {
            state = .error(.serverError)
        }
    }
}
