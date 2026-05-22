import Foundation
@testable import MusicAICodingChallenge

final class StubHTTPTransport: HTTPTransport, @unchecked Sendable {
    typealias Handler = (URLRequest) throws -> (Data, HTTPURLResponse)

    private let handler: Handler
    private(set) var capturedRequests: [URLRequest] = []

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        capturedRequests.append(request)
        return try handler(request)
    }
}

extension StubHTTPTransport {
    static func returning(_ data: Data, status: Int = 200) -> StubHTTPTransport {
        StubHTTPTransport { request in
            let response = HTTPURLResponse(
                url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil
            )!
            return (data, response)
        }
    }

    static func returning(stub: JSONStub, status: Int = 200) -> StubHTTPTransport {
        returning(stub.data, status: status)
    }

    static func failing(with error: Error) -> StubHTTPTransport {
        StubHTTPTransport { _ in throw error }
    }
}
