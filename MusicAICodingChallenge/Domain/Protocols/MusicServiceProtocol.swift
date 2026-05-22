import Foundation

nonisolated protocol MusicServiceProtocol: Sendable {
    func search(query: String, offset: Int, limit: Int) async throws -> SearchResultDTO
    func getAlbum(collectionId: Int) async throws -> [MusicItemDTO]
}
