import Foundation

final class ITunesService: MusicServiceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }

    func search(query: String, offset: Int, limit: Int) async throws -> SearchResultDTO {
        let response: ITunesResponse = try await client.request(
            ITunesEndpoint.search(query: query, offset: offset, limit: limit)
        )
        let items = response.results.compactMap { $0.toDTO() }
        return SearchResultDTO(items: items, totalCount: response.resultCount)
    }

    func getAlbum(collectionId: Int) async throws -> [MusicItemDTO] {
        let response: ITunesResponse = try await client.request(
            ITunesEndpoint.lookup(collectionId: collectionId)
        )
        return response.results
            .filter { $0.wrapperType == "track" && $0.kind == "song" }
            .compactMap { $0.toDTO() }
    }
}
