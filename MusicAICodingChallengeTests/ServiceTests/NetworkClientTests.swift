import Testing
import Foundation
@testable import MusicAICodingChallenge

struct NetworkClientTests {

    private struct EmptyResponse: Decodable, Sendable {}

    private struct DummyEndpoint: Endpoint {
        var baseURL: URL { URL(string: "https://example.com")! }
        var path: String { "/test" }
        var method: HTTPMethod { .get }
    }

    // MARK: - Success
    @Test func successfulRequestDecodesResponse() async throws {
        let json = #"{"value": 42}"#
        let transport = StubHTTPTransport.returning(Data(json.utf8))
        let client = NetworkClient(transport: transport)

        struct Response: Decodable, Sendable { let value: Int }
        let result: Response = try await client.request(DummyEndpoint())

        #expect(result.value == 42)
    }

    // MARK: - Offline error mapping
    @Test func notConnectedToInternetMapsToOffline() async {
        let transport = StubHTTPTransport.failing(with: URLError(.notConnectedToInternet))
        let client = NetworkClient(transport: transport)

        await #expect(throws: MusicError.offline) {
            let _: EmptyResponse = try await client.request(DummyEndpoint())
        }
    }

    @Test func networkConnectionLostMapsToOffline() async {
        let transport = StubHTTPTransport.failing(with: URLError(.networkConnectionLost))
        let client = NetworkClient(transport: transport)

        await #expect(throws: MusicError.offline) {
            let _: EmptyResponse = try await client.request(DummyEndpoint())
        }
    }

    @Test func dataNotAllowedMapsToOffline() async {
        let transport = StubHTTPTransport.failing(with: URLError(.dataNotAllowed))
        let client = NetworkClient(transport: transport)

        await #expect(throws: MusicError.offline) {
            let _: EmptyResponse = try await client.request(DummyEndpoint())
        }
    }

    // MARK: - Server error mapping
    @Test func http500MapsToServerError() async {
        let transport = StubHTTPTransport.returning(Data(), status: 500)
        let client = NetworkClient(transport: transport)

        await #expect(throws: MusicError.serverError) {
            let _: EmptyResponse = try await client.request(DummyEndpoint())
        }
    }

    @Test func http429MapsToServerError() async {
        let transport = StubHTTPTransport.returning(Data("{}".utf8), status: 429)
        let client = NetworkClient(transport: transport)

        await #expect(throws: MusicError.serverError) {
            let _: EmptyResponse = try await client.request(DummyEndpoint())
        }
    }

    @Test func http404MapsToServerError() async {
        let transport = StubHTTPTransport.returning(Data(), status: 404)
        let client = NetworkClient(transport: transport)

        await #expect(throws: MusicError.serverError) {
            let _: EmptyResponse = try await client.request(DummyEndpoint())
        }
    }

    @Test func genericURLErrorMapsToServerError() async {
        let transport = StubHTTPTransport.failing(with: URLError(.timedOut))
        let client = NetworkClient(transport: transport)

        await #expect(throws: MusicError.serverError) {
            let _: EmptyResponse = try await client.request(DummyEndpoint())
        }
    }

    // MARK: - Decoding errors
    @Test func invalidJSONMapsToDecodingFailed() async {
        let transport = StubHTTPTransport.returning(Data("not json".utf8))
        let client = NetworkClient(transport: transport)

        await #expect(throws: MusicError.decodingFailed) {
            let _: EmptyResponse = try await client.request(DummyEndpoint())
        }
    }

    @Test func wrongShapeMapsToDecodingFailed() async {
        let json = #"{"unexpected": true}"#
        let transport = StubHTTPTransport.returning(Data(json.utf8))
        let client = NetworkClient(transport: transport)

        struct Expected: Decodable, Sendable { let required: String }
        await #expect(throws: MusicError.decodingFailed) {
            let _: Expected = try await client.request(DummyEndpoint())
        }
    }

    // MARK: - Cancellation
    @Test func canceledRequestPropagatesCancellation() async {
        let transport = StubHTTPTransport.failing(with: CancellationError())
        let client = NetworkClient(transport: transport)

        await #expect(throws: CancellationError.self) {
            let _: EmptyResponse = try await client.request(DummyEndpoint())
        }
    }

    // MARK: - Request capture
    @Test func requestIsSentToTransport() async throws {
        let json = #"{"value": 1}"#
        let transport = StubHTTPTransport.returning(Data(json.utf8))
        let client = NetworkClient(transport: transport)

        struct Response: Decodable, Sendable { let value: Int }
        let _: Response = try await client.request(DummyEndpoint())

        #expect(transport.capturedRequests.count == 1)
        let captured = try #require(transport.capturedRequests.first)
        #expect(captured.url?.host == "example.com")
        #expect(captured.url?.path == "/test" || captured.url?.path() == "/test")
        #expect(captured.httpMethod == "GET")
    }
}
