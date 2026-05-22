import Foundation

protocol MusicRepositoryProtocol: Sendable {
    func search(query: String, offset: Int, limit: Int) async throws -> SearchResult
    func getRecentlyPlayed(limit: Int) async throws -> [MusicItem]
    func recordPlay(item: MusicItem) async throws
    func getAlbum(collectionId: Int) async throws -> [MusicItem]
}
