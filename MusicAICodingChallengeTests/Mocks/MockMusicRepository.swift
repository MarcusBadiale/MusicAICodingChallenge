import Foundation
@testable import MusicAICodingChallenge

final class MockMusicRepository: MusicRepositoryProtocol, @unchecked Sendable {
    var searchHandler: ((String, Int, Int) async throws -> SearchResult)?
    var recentlyPlayedHandler: ((Int) async throws -> [MusicItem])?
    var recordPlayHandler: ((MusicItem) async throws -> Void)?
    var getAlbumHandler: ((Int) async throws -> [MusicItem])?

    private(set) var searchCallCount = 0
    private(set) var recordPlayCallCount = 0
    private(set) var recordedItems: [MusicItem] = []
    private(set) var recentlyPlayedCallCount = 0
    private(set) var getAlbumCallCount = 0

    func search(query: String, offset: Int, limit: Int) async throws -> SearchResult {
        searchCallCount += 1
        guard let handler = searchHandler else { return SearchResult(items: [], totalCount: 0) }
        return try await handler(query, offset, limit)
    }

    func getRecentlyPlayed(limit: Int) async throws -> [MusicItem] {
        recentlyPlayedCallCount += 1
        guard let handler = recentlyPlayedHandler else { return [] }
        return try await handler(limit)
    }

    func recordPlay(item: MusicItem) async throws {
        recordPlayCallCount += 1
        recordedItems.append(item)
        try await recordPlayHandler?(item)
    }

    func getAlbum(collectionId: Int) async throws -> [MusicItem] {
        getAlbumCallCount += 1
        guard let handler = getAlbumHandler else { return [] }
        return try await handler(collectionId)
    }
}
