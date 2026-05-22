import Foundation

final class MusicRepository: MusicRepositoryProtocol {
    private let service: MusicServiceProtocol
    private let store: MusicModelActor

    init(service: MusicServiceProtocol, store: MusicModelActor) {
        self.service = service
        self.store = store
    }

    func search(query: String, offset: Int, limit: Int) async throws -> SearchResult {
        let dto = try await service.search(query: query, offset: offset, limit: limit)
        return SearchResult(
            items: dto.items.map { $0.toModel() },
            totalCount: dto.totalCount
        )
    }

    func getRecentlyPlayed(limit: Int) async throws -> [MusicItem] {
        try await store.fetchRecentlyPlayed(limit: limit)
    }

    func recordPlay(item: MusicItem) async throws {
        try await store.recordPlay(item: item)
    }

    func getAlbum(collectionId: Int) async throws -> [MusicItem] {
        do {
            let fresh = try await service.getAlbum(collectionId: collectionId)
            let items = fresh.map { $0.toModel() }
            try? await store.saveAlbumTracks(items)
            return items
        } catch {
            let cached = try await store.fetchAlbum(collectionId: collectionId)
            if !cached.isEmpty { return cached }
            throw error
        }
    }
}

// MARK: - DTO → Domain mapping

private extension MusicItemDTO {
    func toModel() -> MusicItem {
        MusicItem(
            id: id,
            trackName: trackName,
            artistName: artistName,
            albumName: albumName,
            artworkUrl: artworkUrl,
            previewUrl: previewUrl,
            trackTimeMillis: trackTimeMillis,
            genre: genre,
            releaseDate: releaseDate,
            collectionId: collectionId,
            trackNumber: trackNumber,
            discNumber: discNumber
        )
    }
}
