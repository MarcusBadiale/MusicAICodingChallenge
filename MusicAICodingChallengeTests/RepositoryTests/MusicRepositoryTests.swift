import Testing
import Foundation
import SwiftData
@testable import MusicAICodingChallenge

struct MusicRepositoryTests {

    // MARK: - Helpers

    private func makeStore() throws -> MusicModelActor {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CachedSong.self, configurations: config)
        return MusicModelActor(modelContainer: container)
    }

    private func makeRepository(
        service: MockMusicService = MockMusicService(),
        store: MusicModelActor
    ) -> MusicRepository {
        MusicRepository(service: service, store: store)
    }

    // MARK: - getRecentlyPlayed

    @Test func recentlyPlayedReturnsEmptyWhenNothingPlayed() async throws {
        let store = try makeStore()
        let repo = makeRepository(store: store)

        let result = try await repo.getRecentlyPlayed(limit: 10)
        #expect(result.isEmpty)
    }

    @Test func recentlyPlayedReturnsSongsOrderedByPlayedAt() async throws {
        let store = try makeStore()
        let repo = makeRepository(store: store)

        let item1 = MusicItem.mock(id: 1, trackName: "First")
        let item2 = MusicItem.mock(id: 2, trackName: "Second")

        try await store.recordPlay(item: item1)
        try await Task.sleep(for: .milliseconds(50))
        try await store.recordPlay(item: item2)

        let result = try await repo.getRecentlyPlayed(limit: 10)
        #expect(result.count == 2)
        #expect(result[0].trackName == "Second")
        #expect(result[1].trackName == "First")
    }

    @Test func recentlyPlayedRespectsLimit() async throws {
        let store = try makeStore()
        let repo = makeRepository(store: store)

        for i in 1...5 {
            try await store.recordPlay(item: .mock(id: i, trackName: "Track \(i)"))
        }

        let result = try await repo.getRecentlyPlayed(limit: 3)
        #expect(result.count == 3)
    }

    @Test func recentlyPlayedIgnoresSongsWithNilPlayedAt() async throws {
        let store = try makeStore()
        let repo = makeRepository(store: store)

        // Save album tracks (playedAt = nil)
        try await store.saveAlbumTracks([.mock(id: 1, trackName: "Album Track")])
        // Play a different track
        try await store.recordPlay(item: .mock(id: 2, trackName: "Played Track"))

        let result = try await repo.getRecentlyPlayed(limit: 10)
        #expect(result.count == 1)
        #expect(result[0].trackName == "Played Track")
    }

    // MARK: - recordPlay

    @Test func recordPlayInsertsNewSong() async throws {
        let store = try makeStore()
        let repo = makeRepository(store: store)

        try await repo.recordPlay(item: .mock(id: 42, trackName: "New Song"))

        let recent = try await repo.getRecentlyPlayed(limit: 10)
        #expect(recent.count == 1)
        #expect(recent[0].id == 42)
        #expect(recent[0].trackName == "New Song")
    }

    @Test func recordPlayUpdatesExistingSongWithoutDuplicating() async throws {
        let store = try makeStore()
        let repo = makeRepository(store: store)

        let item = MusicItem.mock(id: 1)
        try await repo.recordPlay(item: item)
        try await repo.recordPlay(item: item)
        try await repo.recordPlay(item: item)

        let recent = try await repo.getRecentlyPlayed(limit: 10)
        #expect(recent.count == 1)
    }

    @Test func recordPlayUpdatesPlayedAtOnRepeatPlay() async throws {
        let store = try makeStore()
        let repo = makeRepository(store: store)

        let item1 = MusicItem.mock(id: 1, trackName: "Old")
        let item2 = MusicItem.mock(id: 2, trackName: "New")

        try await store.recordPlay(item: item1)
        try await Task.sleep(for: .milliseconds(50))
        try await store.recordPlay(item: item2)
        try await Task.sleep(for: .milliseconds(50))
        // Re-play item1 — should now be most recent
        try await repo.recordPlay(item: item1)

        let recent = try await repo.getRecentlyPlayed(limit: 10)
        #expect(recent[0].trackName == "Old")
        #expect(recent[1].trackName == "New")
    }

    // MARK: - getAlbum (API-first, cache fallback)

    @Test func getAlbumReturnsEmptyWhenAPIReturnsEmpty() async throws {
        let service = MockMusicService()
        service.getAlbumHandler = { _ in [] }
        let store = try makeStore()
        let repo = makeRepository(service: service, store: store)

        let result = try await repo.getAlbum(collectionId: 999)
        #expect(result.isEmpty)
        #expect(service.getAlbumCallCount == 1)
    }

    @Test func getAlbumFetchesFromAPIAndSavesToCache() async throws {
        let service = MockMusicService()
        let tracks: [MusicItemDTO] = [
            .mock(id: 1, trackName: "API Track 1", collectionId: 200),
            .mock(id: 2, trackName: "API Track 2", collectionId: 200),
        ]
        service.getAlbumHandler = { _ in tracks }
        let store = try makeStore()
        let repo = makeRepository(service: service, store: store)

        let result = try await repo.getAlbum(collectionId: 200)
        #expect(result.count == 2)
        #expect(service.getAlbumCallCount == 1)

        // Verify tracks were saved to cache
        let cached = try await store.fetchAlbum(collectionId: 200)
        #expect(cached.count == 2)
    }

    @Test func getAlbumFallsBackToCacheWhenOffline() async throws {
        let service = MockMusicService()
        service.getAlbumHandler = { _ in throw MusicError.offline }
        let store = try makeStore()
        let repo = makeRepository(service: service, store: store)

        // Pre-populate cache
        try await store.saveAlbumTracks([
            .mock(id: 1, trackName: "Cached Track", collectionId: 100, trackNumber: 1, discNumber: 1),
        ])

        let result = try await repo.getAlbum(collectionId: 100)
        #expect(result.count == 1)
        #expect(result[0].trackName == "Cached Track")
    }

    @Test func getAlbumThrowsWhenOfflineAndCacheEmpty() async throws {
        let service = MockMusicService()
        service.getAlbumHandler = { _ in throw MusicError.offline }
        let store = try makeStore()
        let repo = makeRepository(service: service, store: store)

        await #expect(throws: MusicError.offline) {
            try await repo.getAlbum(collectionId: 999)
        }
    }

    @Test func getAlbumPreservesPlayedAtOnExistingSong() async throws {
        let service = MockMusicService()
        let store = try makeStore()
        let repo = makeRepository(service: service, store: store)

        // Record a play first
        try await store.recordPlay(item: .mock(id: 1, trackName: "Played", collectionId: 300))

        // API returns full album including the played song
        service.getAlbumHandler = { _ in [
            .mock(id: 1, trackName: "Played", collectionId: 300, trackNumber: 1, discNumber: 1),
            .mock(id: 2, trackName: "Not Played", collectionId: 300, trackNumber: 2, discNumber: 1),
        ]}

        _ = try await repo.getAlbum(collectionId: 300)

        // The played song should still appear in recently played
        let recent = try await repo.getRecentlyPlayed(limit: 10)
        #expect(recent.count == 1)
        #expect(recent[0].id == 1)
    }

    // MARK: - search (passthrough with mapping)

    @Test func searchDelegatesToService() async throws {
        let service = MockMusicService()
        let dtoResult = SearchResultDTO(
            items: [.mock(id: 1, trackName: "Result")],
            totalCount: 1
        )
        service.searchHandler = { _, _, _ in dtoResult }
        let store = try makeStore()
        let repo = makeRepository(service: service, store: store)

        let result = try await repo.search(query: "test", offset: 0, limit: 20)
        #expect(result.items.count == 1)
        #expect(result.items[0].trackName == "Result")
        #expect(result.totalCount == 1)
        #expect(service.searchCallCount == 1)
    }

    @Test func searchPropagatesOfflineError() async throws {
        let service = MockMusicService()
        service.searchHandler = { _, _, _ in throw MusicError.offline }
        let store = try makeStore()
        let repo = makeRepository(service: service, store: store)

        await #expect(throws: MusicError.offline) {
            try await repo.search(query: "test", offset: 0, limit: 20)
        }
    }
}
