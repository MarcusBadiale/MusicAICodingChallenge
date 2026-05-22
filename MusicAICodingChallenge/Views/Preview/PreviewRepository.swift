import Foundation

#if DEBUG
struct PreviewRepository: MusicRepositoryProtocol {
    func search(query: String, offset: Int, limit: Int) async throws -> SearchResult {
        SearchResult(items: [
            .mock(id: 1, trackName: "Yellow", artistName: "Coldplay", albumName: "Parachutes"),
            .mock(id: 2, trackName: "Fix You", artistName: "Coldplay", albumName: "X&Y"),
            .mock(id: 3, trackName: "The Scientist", artistName: "Coldplay", albumName: "A Rush of Blood to the Head"),
        ], totalCount: 3)
    }

    func getRecentlyPlayed(limit: Int) async throws -> [MusicItem] {
        [
            .mock(id: 1, trackName: "Yellow", artistName: "Coldplay", albumName: "Parachutes"),
            .mock(id: 2, trackName: "Fix You", artistName: "Coldplay", albumName: "X&Y"),
            .mock(id: 3, trackName: "The Scientist", artistName: "Coldplay", albumName: "A Rush of Blood to the Head"),
        ]
    }

    func recordPlay(item: MusicItem) async throws {}

    func getAlbum(collectionId: Int) async throws -> [MusicItem] {
        [
            .mock(id: 1, trackName: "Yellow", artistName: "Coldplay", albumName: "Parachutes", trackNumber: 1),
            .mock(id: 2, trackName: "Shiver", artistName: "Coldplay", albumName: "Parachutes", trackNumber: 2),
            .mock(id: 3, trackName: "Sparks", artistName: "Coldplay", albumName: "Parachutes", trackNumber: 3),
        ]
    }
}
#endif
