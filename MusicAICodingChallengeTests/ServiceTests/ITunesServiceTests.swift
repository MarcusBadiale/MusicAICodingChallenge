import Testing
import Foundation
@testable import MusicAICodingChallenge

struct ITunesServiceTests {

    // MARK: - Helpers

    private func makeService(transport: HTTPTransport) -> ITunesService {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return ITunesService(client: NetworkClient(transport: transport, decoder: decoder))
    }

    // MARK: - Search happy path

    @Test func searchReturnsValidResults() async throws {
        let transport = StubHTTPTransport.returning(stub: .searchAdele)
        let service = makeService(transport: transport)

        let result = try await service.search(query: "Adele", offset: 0, limit: 20)

        #expect(result.totalCount == 2)
        #expect(result.items.count == 2)
        #expect(result.items[0].trackName == "Easy On Me")
        #expect(result.items[0].artistName == "Adele")
        #expect(result.items[0].albumName == "30")
        #expect(result.items[0].id == 1544494118)
    }

    @Test func searchBuildsCorrectURL() async throws {
        let transport = StubHTTPTransport.returning(stub: .searchEmpty)
        let service = makeService(transport: transport)

        _ = try await service.search(query: "Taylor Swift", offset: 20, limit: 10)

        let request = try #require(transport.capturedRequests.first)
        let components = try #require(URLComponents(url: request.url!, resolvingAgainstBaseURL: false))
        let items = components.queryItems ?? []

        #expect(components.host == "itunes.apple.com")
        #expect(components.path == "/search")
        #expect(items.contains(URLQueryItem(name: "term", value: "Taylor Swift")))
        #expect(items.contains(URLQueryItem(name: "media", value: "music")))
        #expect(items.contains(URLQueryItem(name: "entity", value: "song")))
        #expect(items.contains(URLQueryItem(name: "limit", value: "10")))
        #expect(items.contains(URLQueryItem(name: "offset", value: "20")))
    }

    @Test func searchEmptyReturnsZeroItems() async throws {
        let transport = StubHTTPTransport.returning(stub: .searchEmpty)
        let service = makeService(transport: transport)

        let result = try await service.search(query: "xyzabc", offset: 0, limit: 20)

        #expect(result.totalCount == 0)
        #expect(result.items.isEmpty)
    }

    // MARK: - Artwork upscaling

    @Test func artworkURLUpscaledTo600() async throws {
        let transport = StubHTTPTransport.returning(stub: .searchArtwork100)
        let service = makeService(transport: transport)

        let result = try await service.search(query: "test", offset: 0, limit: 20)

        let url = try #require(result.items.first?.artworkUrl)
        #expect(url.absoluteString.contains("600x600bb"))
        #expect(!url.absoluteString.contains("100x100bb"))
    }

    // MARK: - Minimal fields / optional handling

    @Test func minimalFieldsProducesValidDTO() async throws {
        let transport = StubHTTPTransport.returning(stub: .searchMinimalFields)
        let service = makeService(transport: transport)

        let result = try await service.search(query: "test", offset: 0, limit: 20)

        #expect(result.items.count == 1)
        let item = result.items[0]
        #expect(item.trackName == "Minimal Track")
        #expect(item.artistName == "Minimal Artist")
        #expect(item.albumName == nil)
        #expect(item.artworkUrl == nil)
        #expect(item.previewUrl == nil)
        #expect(item.trackTimeMillis == nil)
        #expect(item.genre == nil)
        #expect(item.collectionId == nil)
    }

    // MARK: - Edge cases (inline JSON)

    @Test func skipsTracksWithMissingRequiredFields() async throws {
        let json = """
        {
            "resultCount": 2,
            "results": [
                { "trackId": 1, "trackName": "Valid", "artistName": "A",
                  "wrapperType": "track", "kind": "song" },
                { "trackName": "Missing ID", "artistName": "A",
                  "wrapperType": "track", "kind": "song" }
            ]
        }
        """
        let transport = StubHTTPTransport.returning(Data(json.utf8))
        let service = makeService(transport: transport)

        let result = try await service.search(query: "x", offset: 0, limit: 20)

        #expect(result.totalCount == 2)
        #expect(result.items.count == 1)
        #expect(result.items[0].trackName == "Valid")
    }

    // MARK: - Error mapping

    @Test func offlineErrorMapsToOffline() async {
        let transport = StubHTTPTransport.failing(with: URLError(.notConnectedToInternet))
        let service = makeService(transport: transport)

        await #expect(throws: MusicError.offline) {
            try await service.search(query: "x", offset: 0, limit: 20)
        }
    }

    @Test func serverErrorMapsToServerError() async {
        let transport = StubHTTPTransport.returning(Data(), status: 500)
        let service = makeService(transport: transport)

        await #expect(throws: MusicError.serverError) {
            try await service.search(query: "x", offset: 0, limit: 20)
        }
    }

    @Test func malformedJSONMapsToDecodingFailed() async {
        let transport = StubHTTPTransport.returning(stub: .malformed)
        let service = makeService(transport: transport)

        await #expect(throws: MusicError.decodingFailed) {
            try await service.search(query: "x", offset: 0, limit: 20)
        }
    }

    // MARK: - Album lookup

    @Test func getAlbumFiltersCollectionEntries() async throws {
        let transport = StubHTTPTransport.returning(stub: .albumLookup)
        let service = makeService(transport: transport)

        let tracks = try await service.getAlbum(collectionId: 1544494115)

        #expect(tracks.count == 2)
        #expect(tracks[0].trackName == "Easy On Me")
        #expect(tracks[1].trackName == "Oh My God")
    }

    @Test func getAlbumBuildsCorrectURL() async throws {
        let transport = StubHTTPTransport.returning(stub: .albumLookup)
        let service = makeService(transport: transport)

        _ = try await service.getAlbum(collectionId: 1544494115)

        let request = try #require(transport.capturedRequests.first)
        let components = try #require(URLComponents(url: request.url!, resolvingAgainstBaseURL: false))
        let items = components.queryItems ?? []

        #expect(components.path == "/lookup")
        #expect(items.contains(URLQueryItem(name: "id", value: "1544494115")))
        #expect(items.contains(URLQueryItem(name: "entity", value: "song")))
    }
}
