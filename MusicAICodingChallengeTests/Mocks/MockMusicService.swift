import Foundation
@testable import MusicAICodingChallenge

final class MockMusicService: MusicServiceProtocol, @unchecked Sendable {
    var searchHandler: ((String, Int, Int) async throws -> SearchResultDTO)?
    var getAlbumHandler: ((Int) async throws -> [MusicItemDTO])?

    private(set) var searchCallCount = 0
    private(set) var searchCalls: [(query: String, offset: Int, limit: Int)] = []
    private(set) var getAlbumCallCount = 0

    func search(query: String, offset: Int, limit: Int) async throws -> SearchResultDTO {
        searchCallCount += 1
        searchCalls.append((query, offset, limit))
        guard let handler = searchHandler else { return SearchResultDTO(items: [], totalCount: 0) }
        return try await handler(query, offset, limit)
    }

    func getAlbum(collectionId: Int) async throws -> [MusicItemDTO] {
        getAlbumCallCount += 1
        guard let handler = getAlbumHandler else { return [] }
        return try await handler(collectionId)
    }
}

extension MockMusicService {
    static func returning(_ result: SearchResultDTO) -> MockMusicService {
        let mock = MockMusicService()
        mock.searchHandler = { _, _, _ in result }
        return mock
    }

    static func failing(with error: Error) -> MockMusicService {
        let mock = MockMusicService()
        mock.searchHandler = { _, _, _ in throw error }
        return mock
    }
}
